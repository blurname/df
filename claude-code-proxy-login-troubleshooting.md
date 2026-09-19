# Claude Code 登录 401/403 与代理排障记录

记录日期：2026-09-07

## 现象

Claude Code 原有 OAuth token 过期：

```text
API Error: 401 OAuth access token has expired. Re-authenticate to continue.
```

执行 `claude auth login` 后，浏览器显示授权成功，但终端在用授权码换取 token 时失败：

```text
Login failed: Request failed with status code 403
```

## 排查结论

- v2rayN 已启用 macOS 系统代理和 TUN 路由，流量实际上经过代理。
- Claude Code 进程没有显式的 `HTTP_PROXY` / `HTTPS_PROXY` 环境变量。
- 浏览器 OAuth 授权成功不代表 CLI 的 token exchange 一定成功；后者会请求 `platform.claude.com`。
- 显式为 Claude Code 设置 HTTP 代理后，`claude auth login` 成功。
- 当前 v2rayN 的本地 HTTP 代理监听地址是 `127.0.0.1:10808`。

`10808` 是本机 v2rayN/Xray 的入站端口，不是远程节点端口。即使变量名是 `HTTPS_PROXY`，这里仍使用 `http://`，HTTPS 请求由 HTTP CONNECT 隧道转发。

## 已应用的固定配置

在 `~/.claude/settings.json` 中加入：

```json
{
  "env": {
    "HTTPS_PROXY": "http://127.0.0.1:10808",
    "HTTP_PROXY": "http://127.0.0.1:10808"
  }
}
```

该配置只影响 Claude Code，不会为整个终端全局设置代理。以后可直接运行：

```bash
claude
claude auth login
```

已有 Claude Code 进程需要退出并重新启动，才能稳定使用新凭据和配置。

## 验证方法

查看登录状态：

```bash
claude auth status
```

检查 Claude Code、组织策略和钥匙串状态：

```bash
claude doctor
```

确认本地代理端口正在监听：

```bash
lsof -nP -iTCP:10808 -sTCP:LISTEN
```

确认 macOS 系统代理配置：

```bash
scutil --proxy
```

## 后续注意事项

- 使用 Claude Code 前需确保 v2rayN 正在运行。
- 如果 v2rayN 的本地 HTTP 代理端口发生变化，需要同步修改 `~/.claude/settings.json`。
- 不要重复使用旧的 OAuth 授权 URL；其中的 `state` 和 PKCE 参数是一次性的。
- 若浏览器授权成功但 CLI 再次出现 403/429，先停止重复登录，等待一段时间并检查代理出口是否被 Cloudflare 限流。
- Claude Code 不支持 SOCKS 代理，因此不要把 `HTTPS_PROXY` 配成 `socks5://...`。

## 官方资料

- [Claude Code 网络配置](https://code.claude.com/docs/en/network-config)
- [Claude Code 登录和认证排障](https://code.claude.com/docs/en/troubleshoot-install#login-and-authentication)
- [Claude Code 认证说明](https://code.claude.com/docs/en/authentication)
