local separator = " · "
local labels = {}
local panes = {}
local attached = {}

local function checked(value, err)
  if err then error(err, 0) end
  return value
end

local function git(cwd, ...)
  local argv = { "git", "-C", cwd }
  for _, arg in ipairs({...}) do table.insert(argv, arg) end
  local result = checked(rex.exec(argv, { timeout = 2 }))
  if result.ok then return result.stdout:gsub("\n$", "") end
end

local function shorten(value)
  local chars = {}
  for char in value:gmatch("[^\128-\191][\128-\191]*") do
    if #chars == 127 then return table.concat(chars) .. "…" end
    table.insert(chars, char)
  end
  return value
end

local function project_pane(window)
  local blocks = {}
  for _, layer in ipairs(window.layers) do
    if layer.kind == "tiled" then
      for _, block in ipairs(layer.blocks) do
        if block.creator_name == "com.superlogical.terminal" then
          table.insert(blocks, block.block_id)
        end
      end
    end
  end
  for _, id in ipairs(blocks) do
    if id == window.focused_block_id then return id end
  end
  for _, id in ipairs(blocks) do
    if id == panes[window.window_id] then return id end
  end
  return blocks[1]
end

local function refresh_window(session_id, window)
  local id = window.window_id
  local block_id = project_pane(window)
  if not block_id then return end
  panes[id] = block_id
  local process = rex.block.call("com.superlogical.terminal", "process", {
    session_id = session_id,
    block_id = block_id,
  })
  if not process then return end
  local foreground = process.foreground or process.child
  if not foreground or not foreground.cwd then return end
  local saved = labels[id]
  if not saved or saved.rendered ~= window.label then
    saved = { base = window.label:gsub(" · [^ ]+$", "") }
    labels[id] = saved
  end
  local root = git(foreground.cwd, "rev-parse", "--show-toplevel")
  local branch
  if root then
    branch = git(root, "symbolic-ref", "--quiet", "--short", "HEAD")
      or git(root, "rev-parse", "--short", "HEAD")
    if saved.base:match("^Window %x+$") then
      saved.base = root:match("([^/]+)$")
    end
  end
  local label = shorten(saved.base .. (branch and separator .. branch or ""))
  if label ~= window.label then
    checked(rex.session.set_window_label{
      session_id = session_id,
      window_id = id,
      label = label,
    })
  end
  saved.rendered = label
end

local function refresh()
  local sessions = checked(rex.call("session.list"))
  local live = {}
  for _, session in ipairs(sessions.sessions) do
    if not attached[session.session_id] then
      checked(rex.session.attach{ session_id = session.session_id })
      attached[session.session_id] = true
    end
    local view = rex.session.view{ session_id = session.session_id }
    if view then
      for _, window in ipairs(view.windows) do
        live[window.window_id] = true
        refresh_window(session.session_id, window)
      end
    end
  end
  for id in pairs(labels) do
    if not live[id] then labels[id], panes[id] = nil, nil end
  end
end

if rex.args.once then refresh(); return end

local pending
local function schedule()
  if pending and pending:active() then return end
  pending = rex.after(0.2, refresh)
end

rex.on("terminal.pwd_changed", schedule)
rex.on("terminal.process_changed", schedule)
rex.on("session_view_changed", schedule)
rex.on("session_created", schedule)
rex.on("session_destroyed", function(ctx, ev)
  attached[ev.session_id] = nil
end)
rex.every(3, refresh)
refresh()
