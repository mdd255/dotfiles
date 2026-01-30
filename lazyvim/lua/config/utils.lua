local M = {}

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
      info_label = "Executing command...",
      success_label = "Command executed",
      failed_label = "Command failed: ",
    }

  vim.notify(opts.info_label, vim.log.levels.INFO, opts.notify)

  vim.system(cmd, {}, function(cmd_result)
    vim.schedule(function()
      if cmd_result.code == 0 then
        local message = opts.success_label
        -- Append stdout if available and not empty
        if cmd_result.stdout and cmd_result.stdout ~= "" then
          message = message .. "\n" .. cmd_result.stdout
        end
        vim.notify(message, vim.log.levels.INFO, opts.notify)
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
