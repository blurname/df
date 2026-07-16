#!/usr/bin/env python3
"""herdr 快捷键：在当前项目 tab 启动 pnpm dev，并停掉其他 tab 里的 dev。

用法：dev-switch.sh <目录名前缀> [pane_id]
  目录名前缀   项目根目录名需以此开头（如 voyager），焦点 pane 的 cwd 向上匹配
  pane_id     调试用，指定 pane 代替焦点 pane

- 匹配不到项目根则 toast 提示并退出
- 停掉其他 tab 中 cmdline 匹配 pnpm dev（及 vite/next 子进程）的 pane：先 ctrl+c，超时 kill
- 当前 tab 复用第一个非 agent pane 跑 pnpm dev；没有就向右分一个（ratio 0.5）
"""
import json
import os
import re
import signal
import subprocess
import sys
import time

DEV_RE = re.compile(r"pnpm(\.cjs)?( run)? dev|vite|next dev")
# 快捷键触发时 herdr 会注入 HERDR_BIN_PATH；兜底走 PATH（NixOS 非交互 shell PATH 可能不含 herdr）
HERDR_BIN = os.environ.get("HERDR_BIN_PATH", "herdr")


def herdr(*args):
    out = subprocess.run([HERDR_BIN, *args], capture_output=True, text=True)
    if out.returncode != 0:
        return None
    try:
        return json.loads(out.stdout)["result"]
    except (json.JSONDecodeError, KeyError):
        return None


def notify(msg):
    herdr("notification", "show", "dev-switch", "--body", msg)


def dev_pgid(pane_id, prefix):
    """返回该 pane 前台 dev 进程组 id，没有则 None。"""
    info = herdr("pane", "process-info", "--pane", pane_id)
    if not info:
        return None
    pi = info.get("process_info") or {}
    for proc in pi.get("foreground_processes") or []:
        cmdline = proc.get("cmdline", "")
        cwd = proc.get("cwd", "")
        if DEV_RE.search(cmdline) and os.path.basename(cwd).startswith(prefix):
            return pi.get("foreground_process_group_id")
    return None


def stop_dev(pane_id, prefix):
    herdr("pane", "send-keys", pane_id, "ctrl+c")
    for _ in range(10):
        time.sleep(0.5)
        pgid = dev_pgid(pane_id, prefix)
        if pgid is None:
            return True
    try:
        os.killpg(pgid, signal.SIGTERM)
    except (ProcessLookupError, PermissionError):
        pass
    time.sleep(0.5)
    return dev_pgid(pane_id, prefix) is None


def main():
    if len(sys.argv) < 2:
        notify("用法: dev-switch.sh <目录名前缀> [pane_id]")
        sys.exit(2)
    prefix = sys.argv[1]
    pane_override = sys.argv[2] if len(sys.argv) > 2 else os.environ.get("HERDR_PANE_ID")

    cur = herdr("pane", "current", *(["--pane", pane_override] if pane_override else []))
    if not cur:
        sys.exit(1)
    cur = cur["pane"]
    cwd = cur.get("foreground_cwd") or cur["cwd"]

    root = cwd
    while root not in ("/", ""):
        if os.path.basename(root).startswith(prefix):
            break
        root = os.path.dirname(root)
    else:
        root = None
    if not root or not os.path.basename(root).startswith(prefix):
        notify(f"不是 {prefix}* 项目: {os.path.basename(cwd)}")
        sys.exit(0)

    tab_id = cur["tab_id"]
    panes = (herdr("pane", "list") or {}).get("panes") or []

    for pane in panes:
        pid = pane["pane_id"]
        if pane["tab_id"] == tab_id:
            continue
        if dev_pgid(pid, prefix) is not None and not stop_dev(pid, prefix):
            notify(f"停不掉 {pid} 里的 dev，中止")
            sys.exit(1)

    target = None
    for pane in panes:
        if pane["tab_id"] == tab_id and not pane.get("agent"):
            target = pane["pane_id"]
            break

    if target:
        if dev_pgid(target, prefix) is not None:
            stop_dev(target, prefix)
        herdr("pane", "send-keys", target, "ctrl+c")
        time.sleep(0.3)
        herdr("pane", "run", target, f"cd '{root}' && pnpm dev")
    else:
        created = herdr(
            "pane", "split", "--pane", cur["pane_id"],
            "--direction", "right", "--ratio", "0.5",
            "--cwd", root, "--no-focus",
        )
        new_pane = ((created or {}).get("pane") or {}).get("pane_id")
        if not new_pane:
            notify("分屏失败")
            sys.exit(1)
        time.sleep(0.5)
        herdr("pane", "run", new_pane, "pnpm dev")

    notify(f"dev → {os.path.basename(root)}")


if __name__ == "__main__":
    main()
