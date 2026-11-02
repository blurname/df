local prefix = "alt+`>"

local function bind(key, action, args)
  rex.bind(prefix .. key, action, args)
end

local function checked(result, err)
  if err then error(err, 0) end
  return result
end

local function directory(ctx)
  local process = checked(rex.block.call("com.superlogical.terminal", "process", {
    block_id = ctx.block_id,
  }))
  local foreground = process.foreground or process.child
  if not foreground or not foreground.cwd then
    error("Cannot determine the focused pane's working directory", 0)
  end
  return foreground.cwd
end

local function terminal(command, cwd, label)
  return {
    block = {
      flavor = "com.superlogical.terminal.shell",
      label = label,
      options = {
        command = { "/bin/zsh", "-ic", "exec " .. command },
        shell = "none",
        login = false,
        cwd = cwd,
      },
    },
  }
end

local function overlay(name, title, command, key)
  rex.action{
    name = name,
    title = title,
    run = function(ctx)
      local blocks = checked(rex.session.list_blocks{}).blocks
      local window_id
      for _, block in ipairs(blocks) do
        if block.block_id == ctx.block_id then window_id = block.window_id end
      end
      local label = "rex-tool:" .. name
      for _, block in ipairs(blocks) do
        if block.window_id == window_id and block.label == label then
          return checked(rex.call("block.close", {
            session_id = ctx.session_id,
            block_id = block.block_id,
          }))
        end
      end
      return checked(rex.session.new_layer{
        window_id = window_id,
        bounds = { 0.05, 0.05, 0.9, 0.9 },
        layout = terminal(command, directory(ctx), label),
        focus = true,
      })
    end,
  }
  bind(key, name)
end

bind("t", "client.tab.new")
bind("m", "session.new")
bind("h", "client.tab.previous")
bind("l", "client.tab.next")
bind("w", "pane.close")
bind("shift+w", "client.tab.close")
bind("n", "pane.split", { direction = "right" })
bind("shift+n", "pane.split", { direction = "down" })
bind("r", "client.tab.rename")
bind("f", "pane.zoom")
bind("shift+f", "pane.float")
bind("j", "pane.focus_next")
bind("k", "pane.focus_previous")
bind(",", "session.next")
bind(".", "session.previous")
bind("space", "session.switch")
bind("shift+d", "client.window.close")
bind("alt+`", "pane.send_key", { key = "alt+`" })
rex.bind("cmd+r", "client.config.reload")

for index = 1, 9 do
  bind(tostring(index), "client.tab.goto", { index = index })
end

rex.mode("resize", { exclusive = true })
bind("shift+=", "client.mode.enter", { name = "resize" })
bind("=", "client.mode.enter", { name = "resize" })

for _, direction in ipairs({ "left", "down", "up", "right" }) do
  bind(direction, "pane.focus", { direction = direction })
  rex.bind("resize/" .. direction, "pane.resize", { direction = direction })
  rex.bind("resize/shift+" .. direction, "pane.resize", { direction = direction, amount = 15 })
end

rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/space", "client.mode.exit")
rex.bind("resize/alt+`", "client.mode.exit")

rex.action{
  name = "git_here",
  title = "Toggle ADX Git Overlay",
  run = function(ctx)
    local blocks = checked(rex.session.list_blocks{}).blocks
    local window_id
    for _, block in ipairs(blocks) do
      if block.block_id == ctx.block_id then
        if block.label and block.label:match("^rex%-git:") then
          return checked(rex.session.detach_block{ block_id = block.block_id })
        end
        window_id = block.window_id
      end
    end
    local repository = checked(rex.exec({ "git", "-C", directory(ctx), "rev-parse", "--show-toplevel" }, { timeout = 5 }))
    if not repository.ok then error("The focused pane is not in a Git worktree", 0) end
    local root = repository.stdout:gsub("\n$", "")
    local identity = checked(rex.exec({ "git", "hash-object", "--stdin" }, { stdin = root, timeout = 5 }))
    if not identity.ok then error(identity.stderr, 0) end
    local label = "rex-git:" .. identity.stdout:gsub("\n$", "")
    local bounds = { 0.05, 0.05, 0.9, 0.9 }
    for _, block in ipairs(blocks) do
      if block.label == label then
        if block.window_id == window_id then
          return checked(rex.session.detach_block{ block_id = block.block_id })
        end
        checked(rex.session.move_block{
          block_id = block.block_id,
          anchor_block_id = ctx.block_id,
        })
        checked(rex.session.float_block{ block_id = block.block_id, bounds = bounds })
        return checked(rex.session.focus_block{ block_id = block.block_id })
      end
    end
    return checked(rex.session.new_layer{
      window_id = window_id,
      bounds = bounds,
      layout = terminal("adx git --dir .", root, label),
      focus = true,
    })
  end,
}

bind("g", "git_here")
overlay("caress", "Caress", "adx caress", "i")

rex.action{
  name = "agent_picker",
  title = "Find Agent Across Sessions",
  args = { client = "string?" },
  run = function(ctx, args)
    local client = args and args.client or ""
    if client == "" and (ctx.origin == "key" or ctx.origin == "palette") then
      client = ctx.client_id
    end
    local blocks = checked(rex.session.list_blocks{}).blocks
    local window_id
    for _, block in ipairs(blocks) do
      if block.block_id == ctx.block_id then window_id = block.window_id end
    end
    for _, block in ipairs(blocks) do
      if block.window_id == window_id and block.label == "rex-tool:agents" then
        return checked(rex.block.call("com.superlogical.terminal", "write", {
          block_id = block.block_id,
          data = "\27",
        }))
      end
    end
    return checked(rex.session.new_layer{
      window_id = window_id,
      bounds = { 0.08, 0.15, 0.84, 0.65 },
      layout = {
        block = {
          flavor = "com.superlogical.terminal.shell",
          label = "rex-tool:agents",
          options = {
            command = { "/bin/zsh", "-ic", 'export ADX_REX_FROM_BLOCK="$2"; exec adx agent --rex --client "$1"', "adx-agent", client, ctx.block_id },
            shell = "none",
            login = false,
            cwd = directory(ctx),
          },
        },
      },
      focus = true,
    })
  end,
}

bind("a", "agent_picker")

rex.action{
  name = "floating_shell",
  title = "New Floating Shell Here",
  run = function(ctx)
    return checked(rex.session.new_layer{
      bounds = { 0.1, 0.1, 0.8, 0.8 },
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        options = { cwd = directory(ctx) },
      },
      focus = true,
    })
  end,
}

bind("shift+t", "floating_shell")

rex.action{
  name = "dev_switch",
  title = "Run Voyager Dev Here",
  run = function(ctx)
    local root = directory(ctx)
    while root ~= "/" and not root:match("/voyager[^/]*$") do
      root = root:match("^(.*)/[^/]+$")
      if not root or root == "" then error("The focused pane is not in a voyager project", 0) end
    end
    if root == "/" then error("The focused pane is not in a voyager project", 0) end
    local file = io.open(root .. "/package.json", "r")
    if not file then error("No package.json in " .. root, 0) end
    local content = file:read("*a")
    file:close()
    local package = checked(rex.json.decode(content))
    if not package.scripts or not package.scripts.dev then
      error("No dev script in " .. root .. "/package.json", 0)
    end
    local label = "rex-dev:voyager"
    local sessions = checked(rex.call("session.list"))
    local previous = {}
    for _, session in ipairs(sessions.sessions) do
      checked(rex.call("session.attach", { session_id = session.session_id }))
      local blocks = checked(rex.session.list_blocks{ session_id = session.session_id })
      for _, block in ipairs(blocks.blocks) do
        if block.label == label then
          if block.block_id == ctx.block_id then
            error("Run this action from a project shell or agent pane", 0)
          end
          table.insert(previous, {
            session_id = session.session_id,
            block_id = block.block_id,
          })
        end
      end
    end
    for _, block in ipairs(previous) do
      checked(rex.call("block.close", block))
    end
    return checked(rex.session.new_split{
      anchor_id = ctx.block_id,
      direction = "horizontal",
      side = "after",
      ratio = 0.5,
      layout = terminal("pnpm dev", root, label),
      focus = false,
    })
  end,
}

bind("d", "dev_switch")
