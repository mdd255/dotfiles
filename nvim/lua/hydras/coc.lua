local hydra    = require('hydras._hydra')
local plug_cmd = require('base.utils').plug_cmd
local cmd      = require('hydra.keymap-util').cmd

local function show_docs()
   local cw = vim.fn.expand('<cword>')

   if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
      vim.api.nvim_command('h ' .. cw)
   elseif vim.api.nvim_eval('coc#rpc#ready()') then
      vim.fn.CocActionAsync('doHover')
   else
      vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
   end
end

local keymap = {
   body = 't',
   heads = {
      ['next diag']   = { key = 'n', fn = plug_cmd('coc-diagnostic-next') },
      ['prev diag']   = { key = 'e', fn = plug_cmd('coc-diagnostic-prev') },
      diagnostics     = { key = 'a', fn = cmd 'Telescope coc diagnostics' },
      Diagnostics     = { key = 'A', fn = cmd 'Telescope coc workspace_diagnostics' },
      Symbols         = { key = '<cr>', fn = cmd 'Telescope coc workspace_symbols' },
      implementations = { key = 'i', fn = plug_cmd('coc-diagnostic-implementation') },
      rename          = { key = 'r', fn = plug_cmd('coc-rename') },
      references      = { key = 'f', fn = cmd 'Telescope coc references' },
      definition      = { key = 't', fn = plug_cmd('coc-definition') },
      hover           = { key = 'h', fn = plug_cmd('coc-type-definition') },
      signature       = { key = 's', fn = show_docs },
      help            = { key = 'd', fn = plug_cmd('coc-codeaction-cursor') },
   }
}

hydra.create({
   name = 'LSP',
   keymap = keymap,
})
