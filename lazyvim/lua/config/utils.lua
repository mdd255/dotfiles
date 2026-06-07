local M = {}

-- Shared semantic highlight palette. Keep label colours consistent across the
-- git / gh-actions / docker pickers: ok = success/safe, err = destructive/failed,
-- warn = caution, info = neutral/title, muted = de-emphasised, ident = name/author,
-- text = plain body. Reference these names instead of hardcoding "Diagnostic*".
M.HL = {
  ok = "DiagnosticOk",
  err = "DiagnosticError",
  warn = "DiagnosticWarn",
  info = "DiagnosticInfo",
  muted = "Comment",
  ident = "Function",
  text = "Text",
}

-- Centered floating single-line input. opts: { secret?: bool, default?: string, width?: number }
-- secret=true masks each char as * via extmark conceal.
function M.float_input(prompt, opts, callback)
  local buf = vim.api.nvim_create_buf(false, true)
  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = math.min(opts.width or 50, math.floor(ui.width * 0.9))
  local row = math.floor((ui.height - 3) / 2.5)
  local col = math.floor((ui.width - width) / 2)

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "prompt"
  local prompt_str = " "
  vim.fn.prompt_setprompt(buf, prompt_str)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " " .. prompt .. " ",
    title_pos = "center",
  })

  local border_hl = opts.border_hl or "FloatBorder"
  vim.wo[win].winhighlight = "FloatBorder:" .. border_hl .. ",NormalFloat:SnacksInput"

  if opts.secret then
    local ns = vim.api.nvim_create_namespace("float_input_mask")
    -- conceallevel=2: extmarks with conceal char replace their range in the display.
    -- concealcursor=nicv: conceal active in all modes so * shows even while typing.
    vim.wo[win].conceallevel = 2
    vim.wo[win].concealcursor = "nicv"

    vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
      buffer = buf,
      callback = function()
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
        local plen = #prompt_str
        for i = plen + 1, #line do
          vim.api.nvim_buf_set_extmark(buf, ns, 0, i - 1, { end_col = i, conceal = "*" })
        end
      end,
    })
  end

  if opts.default and opts.default ~= "" then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { prompt_str .. opts.default })
  end

  local done = false
  local function finish(value)
    if done then
      return
    end
    done = true
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    vim.schedule(function()
      callback(value or "")
    end)
  end

  vim.fn.prompt_setcallback(buf, function(text)
    finish(text)
  end)
  vim.fn.prompt_setinterrupt(buf, function()
    finish("")
  end)

  vim.keymap.set({ "n", "i" }, "<Esc>", function()
    finish("")
  end, { buffer = buf, silent = true })

  vim.schedule(function()
    vim.cmd("startinsert!")
  end)
end

-- Prompt the user to type "yes" before running a destructive action. Shared by
-- the git / gh-actions / docker pickers so every irreversible op guards the same
-- way. on_confirm fires only on an exact (case-insensitive) "yes".
-- @param prompt string
-- @param on_confirm function
function M.confirm_dangerous(prompt, on_confirm)
  M.float_input(prompt .. "  Type yes to confirm:", {}, function(input)
    if input and input:lower() == "yes" then
      on_confirm()
    else
      vim.notify("Action cancelled", vim.log.levels.INFO, { title = "Confirm" })
    end
  end)
end

-- Treesitter incremental selection (history-based expand/shrink)
local _ts_history = {}

local function _ts_apply(node)
  local sr, sc, er, ec = node:range()

  if vim.fn.mode() ~= "n" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  end

  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { er + 1, math.max(0, ec - 1) })
end

function M.ts_expand()
  local mode = vim.fn.mode()

  if mode == "n" then
    _ts_history = {}
    local node = vim.treesitter.get_node()

    if not node then
      return
    end

    table.insert(_ts_history, node)
    _ts_apply(node)
    return
  end

  local anchor = vim.fn.getpos("v")
  local cursor = vim.fn.getpos(".")
  local sel_sr = math.min(anchor[2], cursor[2]) - 1
  local sel_sc = math.min(anchor[3], cursor[3]) - 1
  local sel_er = math.max(anchor[2], cursor[2]) - 1
  local sel_ec = math.max(anchor[3], cursor[3]) - 1

  local node = vim.treesitter.get_node({ pos = { sel_sr, sel_sc } })

  while node do
    local nsr, nsc, ner, nec = node:range()
    local nec_inc = nec - 1
    local start_ok = nsr < sel_sr or (nsr == sel_sr and nsc <= sel_sc)
    local end_ok = ner > sel_er or (ner == sel_er and nec_inc >= sel_ec)
    local is_larger = nsr < sel_sr or nsc < sel_sc or ner > sel_er or nec_inc > sel_ec

    if start_ok and end_ok and is_larger then
      break
    end

    node = node:parent()
  end

  if not node then
    return
  end

  table.insert(_ts_history, node)
  _ts_apply(node)
end

function M.ts_shrink()
  table.remove(_ts_history)
  local prev = _ts_history[#_ts_history]
  if not prev then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
    return
  end
  _ts_apply(prev)
end

function M.move_to_start_of_word()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  if line:sub(col + 1, col + 1):match("%w") then
    local s, _ = string.find(line:sub(1, col + 1), "%f[%w]%w*$")

    if s and s - 1 ~= col then
      vim.api.nvim_win_set_cursor(0, { row, s - 1 })
    end
  else
    local keys = vim.api.nvim_replace_termcodes("b", true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
  end
end

-- @param opts table
function M.create_macro(opts)
  if opts.pre_fn then
    opts.pre_fn()
  end

  local expr = vim.api.nvim_replace_termcodes(opts.expr, true, false, true)
  vim.api.nvim_feedkeys(expr, "n", false)
end

function M.term_cmd(cmd)
  vim.cmd("tabnew")
  vim.cmd("LualineRenameTab " .. cmd)
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
end

-- Keymap utility functions
-- @param lhs string|table - keymap or table of keymap configs
-- @param rhs any - command/function (ignored if lhs is table)
-- @param opts? table - options (ignored if lhs is table)
-- @return nil
-- Usage examples:
-- map("H", "<cmd>bprevious<cr>") -- single keymap with default options
-- map("H", "<cmd>bprevious<cr>", { modes = {"n"}, desc = "Previous buffer" })
-- map({
--   {"H", "<cmd>bprevious<cr>", { modes = {"n"}, desc = "Previous" }},
--   {"I", "<cmd>bnext<cr>", { modes = {"n", "v"}, silent = false }},
--   {"<cr>", ":", { modes = {"n"} }}
-- })
function M.map(lhs, rhs, opts)
  -- String form: map("H", rhs, opts) — normalise to the table-of-configs shape
  -- the loop below expects, so the documented single-keymap usage works.
  if type(lhs) == "string" then
    lhs = { { lhs, rhs, opts } }
    opts = nil
  end

  local default_opts = opts or {}

  for _, item in ipairs(lhs) do
    if type(item) == "table" and #item >= 2 then
      -- Table format: {keymap, command, opts}
      local key = item[1]
      local command = item[2]
      local key_opts = vim.tbl_deep_extend("force", {}, default_opts, item[3] or {})
      local modes = key_opts.modes or { "n", "x" }
      key_opts.modes = nil

      if type(modes) ~= "table" then
        modes = { modes }
      end

      if key_opts.noremap == nil then
        key_opts.noremap = true
      end

      if key_opts.silent == nil then
        key_opts.silent = true
      end

      if key_opts.expr == nil then
        key_opts.expr = false
      end

      if key_opts.desc == nil then
        key_opts.desc = command
      end

      vim.keymap.set(modes, key, command, key_opts)
    end
  end
end

-- @param lhs string|table - keymap or table of keymaps/configs
-- @param modes? string|table - default modes if lhs is string, or fallback modes
-- @return nil
-- Usage examples:
-- unmap("H") -- unmap "H" in normal mode
-- unmap("H", {"n", "v"}) -- unmap "H" in normal and visual modes
-- unmap({"H", "I", "m"}) -- unmap multiple keys in normal mode
-- unmap({{"H", {"n", "v"}}, {"I", "n"}, "m"}) -- mixed: H in n+v, I in n, m in default
function M.unmap(lhs, modes)
  local default_modes = modes or { "n" }

  if type(default_modes) ~= "table" then
    default_modes = { default_modes }
  end

  for _, item in ipairs(lhs) do
    if type(item) == "string" then
      -- Simple string keymap, use default modes
      pcall(vim.keymap.del, default_modes, item)
    elseif type(item) == "table" and #item >= 1 then
      -- Table format: {keymap, modes}
      local key = item[1]
      local key_modes = item[2] or default_modes

      if type(key_modes) ~= "table" then
        key_modes = { key_modes }
      end

      pcall(vim.keymap.del, key_modes, key)
    end
  end
end

-- Returns a picker column width clamped between min_cols and max_cols.
-- @param fraction number  - fraction of the terminal width (0–1)
-- @param min_cols  number - minimum column count (default 60)
-- @param max_cols  number - optional maximum column count
-- @return number
function M.picker_width(fraction, min_cols, max_cols)
  local ui = vim.api.nvim_list_uis()[1] or { width = 120 }
  local w = math.max(min_cols or 60, math.floor(ui.width * fraction))
  if max_cols then
    w = math.min(w, max_cols)
  end
  return math.min(w, math.floor(ui.width * 0.9))
end

-- Build a snacks picker `layout` table from declarative options.
-- opts.title: chunk list e.g. { { " text", "HL" } }
-- opts.list_width: when set, splits list + preview horizontally at this fraction.
function M.picker_layout(opts)
  opts = opts or {}
  local content
  if opts.list_width then
    content = {
      box = "horizontal",
      { win = "list", width = opts.list_width },
      { win = "preview", border = "left" },
    }
  else
    content = { win = "list" }
  end
  return {
    layout = {
      title = opts.title,
      box = "vertical",
      position = "float",
      width = M.picker_width(opts.width_frac or 0.5, opts.width_min or 60),
      height = opts.height or 0.4,
      border = "rounded",
      { win = "input", height = 1, border = "bottom" },
      content,
    },
  }
end

-- Parse newline-delimited JSON (one object per line, e.g. `docker ... --format
-- '{{json .}}'`). Bad lines are skipped silently. Returns a list table.
-- @param stdout string|nil
-- @return table
function M.parse_json_lines(stdout)
  local out = {}
  local skipped = 0
  for line in (stdout or ""):gmatch("[^\r\n]+") do
    local ok, data = pcall(vim.json.decode, line)
    if ok and data then
      out[#out + 1] = data
    else
      skipped = skipped + 1
    end
  end
  if skipped > 0 then
    vim.notify(skipped .. " malformed JSON line(s) skipped", vim.log.levels.DEBUG, { title = "parse_json_lines" })
  end
  return out
end

-- Resolve a multi-select picker's effective selection: the explicit multi
-- selection if any, else the item under the cursor, else empty. Centralises the
-- "selected → current → bail" fallback repeated across pickers.
-- @param picker table
-- @return table list of items (possibly empty)
function M.picker_selection(picker)
  local selected = picker:selected()
  if #selected == 0 then
    local item = picker:current()
    if item then
      selected = { item }
    end
  end
  return selected
end

-- Shared single-column floating "action submenu" picker. Used by the docker /
-- gh-actions / package pickers, which were all hand-rolling the same finder +
-- vertical float layout + scheduled-confirm shape.
-- @param items list - finder items (each needs `.text`; `.hl` honoured by default format)
-- @param on_confirm function(item) - runs scheduled, after the picker closes
-- @param opts? table - { title, title_hl, width_frac, width_max, height, format }
-- Default action-row renderer: colour each row by its `.hl` (falling back to the
-- shared `text` group). Items embed their own icon in `.text`, so a single
-- `{ text, hl }` segment keeps every action menu visually identical.
local function menu_default_format(item)
  return { { item.text, item.hl or M.HL.text } }
end

function M.menu_picker(items, on_confirm, opts)
  opts = opts or {}

  require("snacks").picker.pick({
    finder = function()
      return items
    end,
    format = opts.format or menu_default_format,
    layout = {
      layout = {
        title = { { opts.title or " Action", opts.title_hl or "DiagnosticInfo" } },
        box = "vertical",
        position = "float",
        width = M.picker_width(opts.width_frac or 0.2, opts.width_max or 40),
        height = opts.height or 0.4,
        border = "rounded",
        { win = "input", height = 1, border = "bottom" },
        { win = "list" },
      },
    },
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          on_confirm(item)
        end)
      end
    end,
  })
end

-- Returns a `select_and_clear` action for multi-select pickers: toggles the item
-- under the cursor and clears the filter input so the next keystroke starts fresh.
-- advance=true: also moves the cursor down one row (used by the image picker).
function M.select_and_clear_action(advance)
  return function(picker)
    picker.list:select()
    if advance then
      picker.list:move(1)
    end
    vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, { "" })
  end
end

-- Returns a `refresh` action for cached pickers.
-- invalidate_fn() evicts the cache; fetch_fn(cb) is pre-bound with any filter
-- args; populate_fn(data) rebuilds the items upvalue from the fresh payload.
function M.make_refresh_action(invalidate_fn, fetch_fn, populate_fn)
  return function(picker)
    invalidate_fn()
    fetch_fn(function(new_data)
      if not new_data then
        return
      end
      populate_fn(new_data)
      picker:refresh()
    end)
  end
end

function M.exec_async(cmd, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    notify = { title = "CMD" },
    info_label = nil,
    success_label = "Command executed",
    failed_label = "Command failed: ",
    suppress_notify = false,
  })

  if opts.info_label then
    vim.notify(opts.info_label, vim.log.levels.INFO, opts.notify)
  end

  vim.system(cmd, { env = opts.env, timeout = opts.timeout }, function(cmd_result)
    vim.schedule(function()
      if cmd_result.code == 0 then
        local message = opts.success_label or ""

        if cmd_result.stdout and cmd_result.stdout ~= "" then
          message = message .. "\n" .. cmd_result.stdout
        end

        if not opts.suppress_notify then
          vim.notify(message, vim.log.levels.INFO, opts.notify)
        end

        if opts.on_success then
          opts.on_success()
        end
      else
        vim.notify(opts.failed_label .. (cmd_result.stderr or "unknown error"), vim.log.levels.ERROR, opts.notify)

        if opts.on_failure then
          opts.on_failure()
        end
      end
    end)
  end)
end

return M
