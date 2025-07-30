local M = {}

local vscode = vim.g.vscode and require('vscode')

vim.notify = vscode and vscode.notify

function M.map(mode_str, lhs, rhs, current_buffer_only)
  local modes = {}

  for i = 1, #mode_str do
    local mode = mode_str:sub(i, i)
    table.insert(modes, mode)
  end

  local opts = {
    noremap = true,
    silent  = true,
    buffer  = current_buffer_only == true,
    nowait  = true,
  }

  vim.keymap.set(modes, lhs, rhs, opts)
end

---@param action string
---@param keys? string
function M.vscodeAction(action, keys)
  if not vim.g.vscode then return end
  if keys == nil then
    return function() vscode.action(action) end
  end

  return function()
    vscode.call(action)
    vim.defer_fn(function()
      vim.cmd('normal ' .. keys)
    end, 5)
  end
end

function M.which_key(key)
  return function()
    vscode.call('whichkey.show')
    vscode.call('whichkey.triggerKey', { args = { key } })
  end
end

function M.hi(name, opts)
  if opts == nil then opts = {} end
  vim.api.nvim_set_hl(0, name, opts)
end

M.color = {
  black  = '#0a0a0a',
  cyan   = '#2bbac5',
  yellow = '#e5c07b',
  orange = '#d19a66',
  white  = '#ffffff',
  purple = '#d38aea',
  blue   = '#61afef',
  red    = '#ff667c',
  green  = '#89ca78',
  gray   = '#777777',
  select = '#264f78'
}

function M.vscode_config(key, value, scope)
  if scope == nil then scope = 'global' end

  if vscode then
    vscode.update_config(key, value, scope)
  end
end
return M
