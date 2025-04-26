local M = {}

local vscode = {
  call = function(_, _) end,
  action = function(_) end
}

if vim.g.vscode then
  vscode = require('vscode')
  vim.notify = vscode.notify
end

function M.map(mode_str, lhs, rhs, is_silent)
  local modes = {}

  for i = 1, #mode_str do
    local mode = mode_str:sub(i, i)
    table.insert(modes, mode)
  end

  local opts = {
    noremap = true,
    silent  = is_silent == nil or is_silent == true,
    nowait  = true,
  }

  vim.keymap.set(modes, lhs, rhs, opts)
end

---@param action string
---@param keys? string
function M.action(action, keys)
  if keys == nil then
    return function() vscode.action(action) end
  else
    return function()
      vscode.call(action)
      vim.defer_fn(function()
        vim.cmd('normal ' .. keys)
      end, 5)
    end
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
  white  = '#eeeeee',
  purple = '#d38aea',
  blue   = '#61afef',
  red    = '#ef596f',
  green  = '#89ca78',
  gray   = '#777777',
  select = '#264f78'
}

M.higroup = {
  yank_pre      = 'yank_pre',
  del_pre       = 'del_pre',
  change_pre    = 'change_pre',
  paste_post    = 'paste_post',
  hop_next_key  = 'HopNextKey',
  hop_next_key1 = 'HopNextKey1',
  hop_next_key2 = 'HopNextKey2',
}

---@return string
local function get_clipboard_cmd()
  local cmd = {
    Darwin  = 'pbpaste',
    Linux   = 'xclip -o',
    Windows = 'powershell.exe Get-Clipboard'
  }

  local handle = io.popen('uname -s')

  if handle == nil then
    return 'unknown'
  end

  local os_type = handle:read('*a')
  handle:close()

  os_type = os_type:gsub('%s+', '')

  if cmd[os_type] == nil then
    error('Unsupported OS: ' .. os_type)
  end

  return cmd[os_type]
end

---@return number
local function get_clipboard_line_count()
  local clipboard_cmd = get_clipboard_cmd()

  local handle = io.popen(clipboard_cmd)

  if handle ~= nil then
    local content = handle:read('*a')
    handle:close()

    local lines = {}
    for line in content:gmatch('([^\n]*)\n?') do
      table.insert(lines, line)
    end

    return #lines - 1
  end

  return 0
end

-- post paste highlight events
function M.post_paste()
  local count = get_clipboard_line_count()
  vim.cmd('normal! p')
  local ns = vim.api.nvim_create_namespace('post_paste')
  local line = vim.fn.line('.') - 1

  for i = 0, count - 1 do
    vim.api.nvim_buf_add_highlight(0, ns, M.higroup.paste_post, line + i, 0, -1)
  end

  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  end, event_delay_ms)
end

-- pre highlight events
---@param event string
---@param higroup string
---@param extra_cmd? string
function M.pre_highlight(event, higroup, extra_cmd)
  local line = vim.fn.line('.') - 1
  local count = vim.v.count1
  local ns = vim.api.nvim_create_namespace('pre_' .. event)

  for i = 0, count - 1 do
    vim.api.nvim_buf_add_highlight(0, ns, higroup, line + i, 0, -1)
  end

  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    vim.cmd('normal! ' .. count .. event)
    if extra_cmd then vim.cmd(extra_cmd) end
  end, event_delay_ms)
end

return M
