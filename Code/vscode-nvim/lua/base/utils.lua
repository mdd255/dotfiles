local M = {}

local vscode = vim.g.vscode and require('vscode')

vim.notify = vscode and vscode.notify

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

---@param table_key string
---@param key string
---@param value string
function M.update_vscode_config_table(table_key, key, value)
  local table_value = vscode.get_config(table_key)
  table_value[key] = value
  vscode.update_config({ table_key }, { table_value }, 'global')
end

-- post paste highlight events
function M.post_paste(reverse)
  local cmd = reverse and 'normal! P' or 'normal! p'
  vim.cmd(cmd)
  local ns = vim.api.nvim_create_namespace('post_paste')
  local start_line = vim.fn.line('.') - 1
  local clipboard_content = vim.fn.getreg('"')
  local pasted_lines = vim.split(clipboard_content, '\n', { plain = true })

  for i, line_content in ipairs(pasted_lines) do
    local line_index = start_line + i - 1

    if line_content and #line_content > 0 then
      vim.api.nvim_buf_add_highlight(0, ns, M.higroup.paste_post, line_index, 0, -1)
    end
  end

  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  end, event_delay_ms)
end

-- pre highlight events
---@param select string
---@param bgcolor string
---@param act string
function M.pre_highlight(select, bgcolor, act)
  vscode.update_config('animations.CursorAnimation', false, 'global')
  M.update_vscode_config_table('workbench.colorCustomizations', 'editor.selectionBackground', bgcolor)
  local count = vim.v.count
  vim.api.nvim_feedkeys(select, 'n', false)
  for i = 2, count do
    vim.api.nvim_feedkeys('j', 'x', false)
  end
  vim.defer_fn(function()
    vim.cmd('normal! ' .. act)
    if act == 'c' then vim.api.nvim_feedkeys('a', 'n', false) end
    vscode.update_config('animations.CursorAnimation', true, 'global')
    M.update_vscode_config_table('workbench.colorCustomizations', 'editor.selectionBackground', 'default')
  end, event_delay_ms)
end

return M
