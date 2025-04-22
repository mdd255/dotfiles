local M = {}

M.color = {
   black     = '#0a0a0a',
   cyan      = '#2bbac5',
   yellow    = '#e5c07b',
   orange    = '#d19a66',
   white     = '#eeeeee',
   purple    = '#d38aea',
   blue      = '#61afef',
   red       = '#ef596f',
   light_red = '#00ffff',
   green     = '#89ca78',
   gray      = '#777777',
}

function M.map(mode_str, lhs, rhs, isSilent)
   local modes = {}

   for i = 1, #mode_str do
      local mode = mode_str:sub(i, i)
      table.insert(modes, mode)
   end

   local opts = {
      noremap = true,
      silent  = isSilent == true,
      nowait  = true,
   }

   if (isSilent == nil) then opts.silent = true end

   vim.keymap.set(modes, lhs, rhs, opts)
end

function M.plug_cmd(cmd, mode)
   local _mode = mode or 'n'
   local _cmd = '<Plug>(' .. cmd .. ')'
   local raw_cmd = vim.api.nvim_replace_termcodes(_cmd, true, true, true)
   return function() vim.api.nvim_feedkeys(raw_cmd, _mode, true) end
end

function M.source_conf()
   vim.notify('Sourced configurations', 'info', { title = 'System' })
   vim.cmd('source %')
end

return M
