import argparse
import json
import os
from pathlib import Path
import subprocess
import sys


def project_root(directory):
    path = Path(directory).resolve()
    result = subprocess.run(
        ["git", "-C", str(path), "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, timeout=5,
    )
    return Path(result.stdout.strip()).resolve() if result.returncode == 0 else path


def select_pane(rows, directory, inherited_block):
    root = project_root(directory)
    matches = []
    for row in rows:
        process = row.get("process") or {}
        processes = [process.get("foreground"), *(process.get("ancestors") or [])]
        agents = [p for p in processes if p and p.get("name") in ("codex", "claude", "claude-code")]
        if any(p.get("cwd") and project_root(p["cwd"]) == root for p in agents):
            matches.append(row)
    if not matches:
        raise ValueError(f"No Rex Agent pane matches {root}; do not split using inherited IDs")
    windows = {(r["session_id"], r["window_id"]) for r in matches}
    if len(windows) != 1:
        choices = [{k: r[k] for k in ("session_id", "window_id", "block_id", "tab")} for r in matches]
        raise ValueError(f"Multiple Tabs match {root}; choose an explicit pane: {json.dumps(choices, ensure_ascii=False)}")
    selected = next((r for r in matches if r["block_id"] == inherited_block), matches[0])
    return {k: selected[k] for k in ("session_id", "window_id", "block_id", "tab")}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("agent_directory")
    args = parser.parse_args()
    script = '''
local function checked(value, err)
  if err then error(err, 0) end
  return value
end
local rows = {}
for _, session in ipairs(checked(rex.call("session.list")).sessions) do
  checked(rex.session.attach{session_id=session.session_id})
  local view = checked(rex.session.view{session_id=session.session_id})
  for _, window in ipairs(view.windows) do
    for _, layer in ipairs(window.layers) do
      if layer.kind == "tiled" then
        for _, block in ipairs(layer.blocks) do
          if block.creator_name == "com.superlogical.terminal" then
            local process = rex.block.call("com.superlogical.terminal", "process", {
              session_id=session.session_id, block_id=block.block_id,
            })
            if process then
              table.insert(rows, {session_id=session.session_id, window_id=window.window_id,
                block_id=block.block_id, tab=window.label, process=process})
            end
          end
        end
      end
    end
  end
end
return {panes=rows}
'''
    result = subprocess.run(["rex", "do", "-e", script, "--json"],
                            check=True, capture_output=True, text=True, timeout=30)
    rows = json.loads(result.stdout)["panes"]
    selected = select_pane(rows, args.agent_directory, os.environ.get("REX_BLOCK"))
    print(json.dumps(selected, ensure_ascii=False))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
