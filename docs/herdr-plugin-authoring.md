# Herdr Plugin Authoring Notes

This is a compact reference for writing and publishing Herdr plugins.

Official docs:

- https://herdr.dev/docs/plugins/
- https://herdr.dev/docs/socket-api/
- https://herdr.dev/docs/marketplace/

## Core Model

A Herdr plugin is a directory with a `herdr-plugin.toml` manifest and executable
commands. There is no separate SDK. The plugin process calls back into Herdr
through the Herdr CLI or the socket API.

Herdr owns:

- plugin install/link/unlink
- manifest validation
- keybindings
- pane launching
- event hook dispatch
- runtime context injection
- plugin command logs

The plugin owns:

- implementation language
- dependencies
- config file format
- durable state
- tests

Actions, event hooks, panes, and link handlers are declared in the manifest.
Herdr plugin v1 does not support runtime action registration or native
non-terminal plugin UI.

## Recommended Repository Layout

```text
my-herdr-plugin/
  herdr-plugin.toml
  script.sh
  test.sh
  README.md
  LICENSE
```

Use a standalone public repository when publishing a plugin. Marketplace listings
use GitHub repository metadata, so putting a public plugin inside dotfiles makes
the listing unclear.

## Minimal Manifest

```toml
id = "owner.plugin-name"
name = "Plugin Name"
version = "0.1.0"
min_herdr_version = "0.7.0"
description = "What this plugin does."
platforms = ["linux", "macos"]

[[actions]]
id = "refresh"
title = "Refresh"
description = "Run the refresh action."
contexts = ["workspace", "tab", "pane"]
command = ["./script.sh"]

[[events]]
on = "pane.focused"
command = ["./script.sh"]
```

Required top-level fields:

- `id`
- `name`
- `version`
- `min_herdr_version`

Optional but recommended:

- `description`
- `platforms`

`command` values are argv arrays. Herdr does not run them through a shell. If a
command needs shell behavior, put that behavior in an executable script and call
the script from the manifest.

## Naming Rules

Plugin ids may use ASCII letters, digits, dot, colon, underscore, and hyphen:

```text
owner.plugin-name
```

Action ids, pane ids, and link handler ids are local ids inside the plugin.
They may use ASCII letters, digits, colon, underscore, and hyphen, but not dots.

An action's qualified id is:

```text
plugin.id.action
```

Example:

```text
blurname.git-tab-name.refresh
```

## Runtime Environment

Runtime commands run with the plugin directory as their working directory.

Common injected environment variables:

```text
HERDR_SOCKET_PATH
HERDR_BIN_PATH
HERDR_ENV=1
HERDR_PLUGIN_ID
HERDR_PLUGIN_ROOT
HERDR_PLUGIN_CONFIG_DIR
HERDR_PLUGIN_STATE_DIR
HERDR_PLUGIN_CONTEXT_JSON
HERDR_WORKSPACE_ID
HERDR_TAB_ID
HERDR_PANE_ID
```

Additional variables by entrypoint type:

```text
HERDR_PLUGIN_ACTION_ID       # action commands
HERDR_PLUGIN_EVENT           # event hooks
HERDR_PLUGIN_EVENT_JSON      # event hooks
HERDR_PLUGIN_ENTRYPOINT_ID   # pane commands
HERDR_PLUGIN_CLICKED_URL     # link handlers
HERDR_PLUGIN_LINK_HANDLER_ID # link handlers
```

Use `HERDR_BIN_PATH` when calling Herdr from a plugin:

```sh
herdr_bin="${HERDR_BIN_PATH:-herdr}"
"$herdr_bin" tab rename "$tab_id" "$label"
```

Do not store credentials or durable user data under `HERDR_PLUGIN_ROOT`, because
GitHub-installed plugin roots are managed source checkouts. Put user-editable
config under `HERDR_PLUGIN_CONFIG_DIR` and runtime state under
`HERDR_PLUGIN_STATE_DIR`.

## Context JSON

`HERDR_PLUGIN_CONTEXT_JSON` can include workspace, tab, focused pane, worktree,
agent, selected text, clicked URL, and link handler fields when available.

Shell parsing example:

```sh
tab_id="$(python3 - <<'PY'
import json
import os

ctx = json.loads(os.environ.get("HERDR_PLUGIN_CONTEXT_JSON") or "{}")
print(ctx.get("tab_id") or "")
PY
)"
```

Useful context fields seen in practice:

```text
workspace_id
workspace_label
workspace_cwd
worktree
tab_id
tab_label
focused_pane_id
focused_pane_cwd
focused_pane_agent
focused_pane_status
selected_text
invocation_source
correlation_id
clicked_url
link_handler_id
```

## Calling Herdr

Prefer CLI wrappers for simple automation. Use the raw socket API only when you
need direct request/response control or long-lived subscriptions.

Common plugin development commands:

```bash
herdr plugin link /path/to/plugin
herdr plugin config-dir owner.plugin
herdr plugin action list --plugin owner.plugin
herdr plugin action invoke owner.plugin.action
herdr plugin pane open --plugin owner.plugin --entrypoint pane-id
herdr plugin log list --plugin owner.plugin
herdr plugin unlink owner.plugin
```

Common Herdr control commands from plugin scripts:

```bash
herdr workspace list
herdr tab list
herdr tab rename <tab_id> <label>
herdr pane current
herdr pane list
herdr pane read <pane_id> --source recent --lines 50
herdr notification show "title" --body "body"
```

## Event Hooks

Event hooks are declared in `[[events]]` blocks:

```toml
[[events]]
on = "pane.focused"
command = ["./script.sh"]
```

Useful low-volume events:

```text
workspace.created
workspace.updated
workspace.closed
workspace.renamed
workspace.moved
workspace.focused
worktree.created
worktree.opened
worktree.removed
tab.created
tab.closed
tab.renamed
tab.moved
tab.focused
pane.created
pane.closed
pane.focused
pane.moved
pane.exited
pane.agent_detected
pane.agent_status_changed
```

Do not assume every internal event is available to plugin hooks. High-volume
events such as output changes are intentionally not exposed as manifest hooks in
v1.

## Actions And Keybindings

Declare an action:

```toml
[[actions]]
id = "refresh"
title = "Refresh"
contexts = ["workspace", "tab", "pane"]
command = ["./script.sh"]
```

Bind it in `~/.config/herdr/config.toml`:

```toml
[[keys.command]]
key = "prefix+g"
type = "plugin_action"
command = "owner.plugin-name.refresh"
description = "refresh plugin"
```

Reload config:

```bash
herdr server reload-config
```

## Panes

Manifest panes open plugin-provided terminal panes:

```toml
[[panes]]
id = "board"
title = "Project board"
placement = "overlay"
command = ["./board.sh"]
```

`placement` defaults to `overlay`. A `plugin.pane.open` request can override it
with:

```text
overlay
split
tab
zoomed
```

After opening, plugin panes are normal Herdr panes and can be moved, resized,
swapped, and zoomed through the regular Herdr API.

## Link Handlers

Link handlers route modified clicks on matching terminal URLs to a plugin
action:

```toml
[[link_handlers]]
id = "github-issue"
title = "Open GitHub issue"
pattern = "^https://github\\.com/[^/]+/[^/]+/(issues|pull)/[0-9]+$"
action = "open"
```

The pattern is a Rust regular expression. The action must be declared by the
same plugin. The modified-click modifier is Control on all platforms.

Link handler actions receive clicked URL context through
`HERDR_PLUGIN_CONTEXT_JSON`, `HERDR_PLUGIN_CLICKED_URL`, and
`HERDR_PLUGIN_LINK_HANDLER_ID`.

## Build Commands

Build commands run during GitHub `plugin install`, after confirmation and before
registration:

```toml
[[build]]
command = ["npm", "ci"]

[[build]]
command = ["npm", "run", "build"]
platforms = ["linux", "macos"]
```

Local `plugin link` does not run build commands. Local authors should build the
working tree themselves.

Build commands do not receive runtime plugin context or Herdr socket env.
Document required tools such as `npm`, `bun`, `cargo`, or `python3`.

## Testing Checklist

Basic script checks:

```bash
bash -n script.sh
bash -n test.sh
bash test.sh
```

Manifest validation without leaving the plugin enabled:

```bash
herdr plugin link /path/to/plugin --disabled
herdr plugin list --json --plugin owner.plugin
herdr plugin unlink owner.plugin
```

Action validation:

```bash
herdr plugin link /path/to/plugin
herdr plugin action list --plugin owner.plugin
herdr plugin action invoke owner.plugin.action
herdr plugin log list --plugin owner.plugin
```

GitHub install validation:

```bash
herdr plugin install owner/repo --yes
herdr plugin list --json --plugin owner.plugin
```

## Publishing

Create a public GitHub repo with `herdr-plugin.toml` at the repo root or in a
subdirectory.

Install command for users:

```bash
herdr plugin install owner/repo
```

Subdirectory install:

```bash
herdr plugin install owner/repo/path/to/plugin
```

Marketplace listing requirements:

- public GitHub repository
- GitHub topic `herdr-plugin`
- not private
- not archived
- not a fork

Marketplace refreshes automatically about every 30 minutes. The listing is not
reviewed. In v1, marketplace cards use GitHub repository metadata only; they do
not parse `herdr-plugin.toml`.

Useful publish commands:

```bash
gh repo create owner/repo --public --source . --push \
  --description "Short plugin description."

gh repo edit owner/repo --add-topic herdr-plugin
```

## Common Pitfalls

- `command` does not run through a shell.
- Use `HERDR_BIN_PATH` instead of hard-coding `herdr`.
- Do not write credentials or durable user state into `HERDR_PLUGIN_ROOT`.
- Local `plugin link` does not run build commands.
- GitHub `plugin install` refuses to install over a locally linked plugin with
  the same id.
- There is no separate `plugin update` in v1; reinstall from GitHub to refresh.
- Event hooks are not available for every internal event.
- Avoid high-frequency polling unless the plugin owns throttling and cleanup.
- Keep plugin ids stable after publishing; changing ids breaks user keybindings.

## Example: Git Tab Name

Repo:

```text
https://github.com/blurname/herdr-git-tab-name
```

Install:

```bash
herdr plugin install blurname/herdr-git-tab-name
```

Action id:

```text
blurname.git-tab-name.refresh
```

Manual keybinding:

```toml
[[keys.command]]
key = "prefix+g"
type = "plugin_action"
command = "blurname.git-tab-name.refresh"
description = "refresh tab name from git branch"
```
