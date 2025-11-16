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
function M.create_marcro(opts)
  if opts.pre_fn then
    opts.pre_fn()
  end

  local expr = vim.api.nvim_replace_termcodes(opts.expr, true, false, true)
  vim.api.nvim_feedkeys(expr, "n", false)
end

return M
