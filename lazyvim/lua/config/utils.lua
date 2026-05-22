local M = {}

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

function M.exec_async(cmd, opts)
  opts = opts
    or {
      notify = { title = "CMD" },
      info_label = nil,
      success_label = "Command executed",
      failed_label = "Command failed: ",
      supress_notify = false,
    }

  if opts.info_label then
    vim.notify(opts.info_label, vim.log.levels.INFO, opts.notify)
  end

  vim.system(cmd, {}, function(cmd_result)
    vim.schedule(function()
      if cmd_result.code == 0 then
        local message = opts.success_label or ""

        if cmd_result.stdout and cmd_result.stdout ~= "" then
          message = message .. "\n" .. cmd_result.stdout
        end

        if not opts.supress_notify then
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
