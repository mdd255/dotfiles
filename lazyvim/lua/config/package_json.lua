local utils = require("config.utils")
local exec_async = utils.exec_async
local picker_width = utils.picker_width
local picker_selection = utils.picker_selection
local snacks = require("snacks")

local M = {}

local notify_opts = { title = "Package.json" }
local HISTORY_FILE = vim.fn.stdpath("data") .. "/pkgjson_args_history.json"
local MAX_HISTORY = 20

-- ── Utilities ───────────────────────────────────────────────────────────────

local function find_pkg_root()
  -- Search upward from the CURRENT FILE's directory, not the cwd. In a monorepo
  -- the cwd is usually the repo root, so `.;` would always resolve the root
  -- package.json even when editing packages/foo/*. Anchor to the buffer's dir.
  local base = vim.fn.expand("%:p:h")

  if base == "" then
    base = "."
  end

  local path = vim.fn.findfile("package.json", base .. ";")

  if path == "" then
    return nil
  end

  return vim.fn.fnamemodify(path, ":p:h")
end

local function read_json(path)
  local f = io.open(path, "r")

  if not f then
    return nil
  end

  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)

  if not ok then
    vim.notify("Failed to parse JSON: " .. path, vim.log.levels.DEBUG, notify_opts)
    return nil
  end

  return data
end

local function get_pkg_manager(root)
  if vim.fn.filereadable(root .. "/yarn.lock") == 1 then
    return "yarn"
  end

  if vim.fn.filereadable(root .. "/pnpm-lock.yaml") == 1 then
    return "pnpm"
  end

  return "npm"
end

local function open_url(url)
  if vim.ui.open then
    vim.ui.open(url)
  else
    local opener = vim.fn.has("mac") == 1 and "open" or "xdg-open"
    vim.fn.jobstart({ opener, url }, { detach = true })
  end

  vim.notify("Opening " .. url, vim.log.levels.INFO, notify_opts)
end

-- ── Args history ──────────────────────────────────────────────────────────────

local function load_history()
  return read_json(HISTORY_FILE) or {}
end

local function save_history(h)
  local f = io.open(HISTORY_FILE, "w")

  if f then
    f:write(vim.json.encode(h))
    f:close()
  end
end

local function get_history(key)
  return load_history()[key] or {}
end

local function add_to_history(key, args)
  if args == "" then
    return
  end

  local h = load_history()
  h[key] = h[key] or {}

  for i, v in ipairs(h[key]) do
    if v == args then
      table.remove(h[key], i)
      break
    end
  end

  table.insert(h[key], 1, args)

  while #h[key] > MAX_HISTORY do
    table.remove(h[key])
  end

  save_history(h)
end

-- ── Output popup ────────────────────────────────────────────────────────────

local function show_output(title, lines)
  if #lines == 0 then
    lines = { "(no output)" }
  end

  local width = picker_width(0.82, 80)
  local height = math.min(math.floor(vim.o.lines * 0.72), #lines + 2)

  snacks.win({
    title = " " .. title .. " ",
    title_pos = "center",
    -- Pass lines as a table (set directly, no concat+resplit). No `ft`: a
    -- filetype makes snacks attach treesitter/syntax to the whole buffer, which
    -- is what made huge output (70k+ lines) lag badly.
    text = lines,
    width = width,
    height = height,
    border = "rounded",
    wo = { wrap = false, cursorline = false, number = false },
    keys = {
      q = "close",
      ["<Esc>"] = "close",
    },
  })
end

-- ── Async command runner (with output popup) ──────────────────────────────────

local _run_seq = 0

local function run_with_output(root, cmd, title)
  _run_seq = _run_seq + 1
  local notif_id = "pkgjson_run_" .. _run_seq

  -- Persistent notification (timeout = false): stays up while the script runs,
  -- dismissed once the output popup is ready. Call snacks.notifier directly —
  -- vim.notify is intercepted by noice, so snacks.notifier.hide() can't match
  -- the id and the toast would expire on noice's own timeout instead.
  snacks.notifier.notify(" " .. table.concat(cmd, " "), "info", {
    id = notif_id,
    timeout = false,
    title = notify_opts.title,
  })

  vim.system(cmd, { cwd = root, text = true }, function(res)
    vim.schedule(function()
      local lines = {}
      for _, chunk in ipairs({ res.stdout, res.stderr }) do
        if chunk and chunk ~= "" then
          vim.list_extend(lines, vim.split(chunk:gsub("\27%[[%d;]*m", ""), "\n", { trimempty = true }))
        end
      end
      snacks.notifier.hide(notif_id)
      show_output(title .. "  [exit:" .. res.code .. "]", lines)
    end)
  end)
end

local function build_run_cmd(pm, script, args)
  if args ~= "" then
    local s = vim.fn.shellescape(script)
    local base = pm == "npm" and ("npm run " .. s) or pm == "yarn" and ("yarn " .. s) or ("pnpm run " .. s)
    return { "sh", "-c", base .. " -- " .. args }
  end

  return pm == "npm" and { "npm", "run", script } or pm == "yarn" and { "yarn", script } or { "pnpm", "run", script }
end

-- ── Packages ──────────────────────────────────────────────────────────────────

local open_packages_picker

-- YAML-safe double-quoted scalar. Plain scalars starting with reserved
-- indicators (notably `@` for scoped package names) are invalid YAML and break
-- treesitter highlighting for the rest of the buffer. Quoting + escaping avoids it.
local function yq(v)
  v = tostring(v == nil and "—" or v)
  v = v:gsub("\\", "\\\\"):gsub('"', '\\"')
  return '"' .. v .. '"'
end

local function package_preview(p)
  return table.concat({
    "Name:         " .. yq(p.name),
    "Spec:         " .. yq(p.spec),
    "Installed:    " .. yq(p.version),
    "Type:         " .. yq(p.is_dev and "devDependency" or "dependency"),
    "License:      " .. yq(p.license or "—"),
    "Description:  " .. yq(p.description ~= "" and p.description or "—"),
    "Homepage:     " .. yq(p.homepage or "—"),
    "Npm:          " .. yq("https://www.npmjs.com/package/" .. p.name),
  }, "\n")
end

local PACKAGE_ACTIONS = {
  { text = "󰊯 open on npm", key = "npm" },
  { text = "󰚰 update", key = "update" },
  { text = " uninstall", key = "uninstall" },
  { text = " homepage", key = "homepage" },
}

local function build_pkg_mutate_cmd(pm, action, names)
  local map = {
    npm = { uninstall = { "npm", "uninstall" }, update = { "npm", "update" } },
    yarn = { uninstall = { "yarn", "remove" }, update = { "yarn", "upgrade" } },
    pnpm = { uninstall = { "pnpm", "remove" }, update = { "pnpm", "update" } },
  }
  return vim.list_extend(vim.deepcopy(map[pm][action]), names)
end

local function run_package_action(action_key, packages, root, pm)
  if action_key == "npm" then
    for _, p in ipairs(packages) do
      open_url("https://www.npmjs.com/package/" .. p.name)
    end
  elseif action_key == "homepage" then
    for _, p in ipairs(packages) do
      if p.homepage then
        open_url((p.homepage:gsub("^git%+", ""):gsub("%.git$", "")))
      else
        vim.notify("No homepage for " .. p.name, vim.log.levels.WARN, notify_opts)
      end
    end
  elseif action_key == "uninstall" or action_key == "update" then
    local names = vim.tbl_map(function(p)
      return p.name
    end, packages)
    local verb = action_key == "uninstall" and "Uninstalling" or "Updating"

    exec_async(build_pkg_mutate_cmd(pm, action_key, names), {
      notify = notify_opts,
      info_label = verb .. " " .. table.concat(names, ", ") .. "...",
      success_label = action_key .. " done: " .. table.concat(names, ", "),
      failed_label = "Failed to " .. action_key .. ": ",
      on_success = function()
        vim.schedule(open_packages_picker)
      end,
    })
  end
end

local function show_action_picker(selected, root, pm)
  utils.menu_picker(PACKAGE_ACTIONS, function(item)
    run_package_action(item.key, selected, root, pm)
  end)
end

open_packages_picker = function()
  local root = find_pkg_root()
  if not root then
    vim.notify("No package.json found", vim.log.levels.WARN, notify_opts)
    return
  end

  local pkg = read_json(root .. "/package.json")
  if not pkg then
    vim.notify("Cannot parse package.json", vim.log.levels.ERROR, notify_opts)
    return
  end

  local items = {}

  local function collect(deps, is_dev)
    for name, spec in pairs(deps or {}) do
      local info = read_json(root .. "/node_modules/" .. name .. "/package.json")
      local repo = info and info.repository

      local homepage = (info and info.homepage)
        or (type(repo) == "string" and repo)
        or (type(repo) == "table" and repo.url)
        or nil

      table.insert(items, {
        name = name,
        spec = spec,
        version = info and info.version or "—",
        description = info and info.description or "",
        license = type(info and info.license) == "string" and info.license or "—",
        homepage = homepage,
        is_dev = is_dev,
      })
    end
  end

  collect(pkg.dependencies, false)
  collect(pkg.devDependencies, true)

  if #items == 0 then
    vim.notify("No dependencies found", vim.log.levels.WARN, notify_opts)
    return
  end

  table.sort(items, function(a, b)
    if a.is_dev ~= b.is_dev then
      return not a.is_dev
    end
    return a.name < b.name
  end)

  local pm = get_pkg_manager(root)

  for _, p in ipairs(items) do
    p.text = string.format("%-32s %-14s", p.name, p.version)
    p.preview = { text = package_preview(p), ft = "yaml" }
  end

  snacks.picker.pick({
    finder = function()
      return items
    end,
    format = function(item, _)
      return {
        { string.format("%-55s ", item.name), item.is_dev and "Comment" or "Function" },
        { string.format("%-14s ", item.version), "Text" },
      }
    end,
    preview = "preview",
    layout = {
      layout = {
        title = {
          {
            string.format("  Packages · %s · %d deps", pm, #items),
            "DiagnosticInfo",
          },
        },
        box = "vertical",
        position = "float",
        width = picker_width(0.9, 100),
        height = 0.75,
        border = "rounded",
        { win = "input", height = 1, border = "bottom" },
        {
          box = "horizontal",
          { win = "list", width = 0.5 },
          { win = "preview", border = "left" },
        },
      },
    },
    multi = { "confirm" },
    actions = {
      select_and_clear = function(picker)
        picker.list:select()
        vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, { "" })
      end,
    },
    win = {
      input = {
        keys = {
          ["<Tab>"] = { "select_and_clear", mode = { "i", "n" } },
        },
      },
    },
    confirm = function(picker)
      local selected = picker_selection(picker)
      picker:close()
      if #selected == 0 then
        return
      end

      vim.schedule(function()
        show_action_picker(selected, root, pm)
      end)
    end,
  })
end

function M.pick_packages()
  open_packages_picker()
end

-- ── Scripts ─────────────────────────────────────────────────────────────────

local function pick_args_and_run(root, pm, script)
  local key = root .. "|" .. script
  local history = get_history(key)

  local items = {}
  for _, h in ipairs(history) do
    table.insert(items, { text = h })
  end

  -- Custom run action bound to <CR>. Replaces the built-in `confirm`, whose
  -- guard warns "No results" and bails when the list is empty (no history) or
  -- the typed args match nothing. Typed text wins (new arg); falls back to the
  -- highlighted history entry when the input is empty.
  local function run_args(picker)
    local typed = vim.trim(table.concat(vim.api.nvim_buf_get_lines(picker.input.win.buf, 0, -1, false), ""))
    local item = picker:current()
    picker:close()

    local args = typed ~= "" and typed or (item and item.text) or ""
    add_to_history(key, args)
    run_with_output(root, build_run_cmd(pm, script, args), pm .. " run " .. script)
  end

  snacks.picker.pick({
    finder = function()
      return items
    end,
    format = function(item, _)
      return { { item.text, "DiagnosticInfo" } }
    end,
    -- Keep the picker open with an empty list (no history yet). Without this,
    -- picker.lua closes + warns "No results" before the input is usable.
    show_empty = true,
    live = true,
    layout = {
      layout = {
        title = {
          {
            "  Args · " .. pm .. " run " .. script .. "  (type new / pick history / <CR> empty = none)",
            "DiagnosticInfo",
          },
        },
        box = "vertical",
        position = "float",
        width = picker_width(0.5, 60),
        height = 0.4,
        border = "rounded",
        { win = "input", height = 1, border = "bottom" },
        { win = "list" },
      },
    },
    actions = {
      run_args = run_args,
    },
    win = {
      input = {
        keys = {
          ["<CR>"] = { "run_args", mode = { "i", "n" } },
        },
      },
    },
  })
end

function M.pick_scripts()
  local root = find_pkg_root()

  if not root then
    vim.notify("No package.json found", vim.log.levels.WARN, notify_opts)
    return
  end

  local pkg = read_json(root .. "/package.json")

  if not pkg or not pkg.scripts or next(pkg.scripts) == nil then
    vim.notify("No scripts in package.json", vim.log.levels.WARN, notify_opts)
    return
  end

  local pm = get_pkg_manager(root)

  local items = {}

  for name, cmd in pairs(pkg.scripts) do
    table.insert(items, {
      name = name,
      cmd = cmd,
      text = name,
      preview = { text = pm .. " run " .. name .. "\n\n" .. cmd, ft = "sh" },
    })
  end

  table.sort(items, function(a, b)
    return a.name < b.name
  end)

  snacks.picker.pick({
    finder = function()
      return items
    end,
    format = function(item, _)
      return {
        { string.format("%-28s ", item.name), "Function" },
      }
    end,
    preview = "preview",
    layout = {
      layout = {
        title = { { "  Scripts · " .. pm, "DiagnosticInfo" } },
        box = "vertical",
        position = "float",
        width = picker_width(0.8, 90),
        height = 0.6,
        border = "rounded",
        { win = "input", height = 1, border = "bottom" },
        {
          box = "horizontal",
          { win = "list", width = 0.3 },
          { win = "preview", border = "left" },
        },
      },
    },
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          pick_args_and_run(root, pm, item.name)
        end)
      end
    end,
  })
end

-- ── Setup ─────────────────────────────────────────────────────────────────────

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("PkgJsonKeymaps", { clear = true }),
    pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact", "json" },
    callback = function(ev)
      if not find_pkg_root() then
        return
      end

      local o = { buffer = ev.buf, silent = true }
      vim.keymap.set("n", "<Leader>pp", M.pick_packages, vim.tbl_extend("force", o, { desc = "npm: packages" }))
      vim.keymap.set("n", "<Leader>ps", M.pick_scripts, vim.tbl_extend("force", o, { desc = "npm: scripts" }))
    end,
  })
end

M.setup()
return M
