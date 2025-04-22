local map = require('base.utils').map

local keycodes = {
   rest_run = '<LEADER><LEADER>',
   rest_run_last = '<LEADER><TAB>',
}

return {
   {
      'rest-nvim/rest.nvim',
      ft = { 'http' },
      dependencies = {
         'nvim-treesitter/nvim-treesitter',
         opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            table.insert(opts.ensure_installed, 'http')

            vim.api.nvim_create_autocmd(
               'BufEnter',
               {
                  pattern = '*.http',
                  callback = function()
                     vim.cmd(':LualineRenameTab http')
                     vim.cmd('set ft=http')
                     map('n', keycodes.rest_run, ':Rest run<CR>')
                     map('n', keycodes.rest_run_last, ':Rest last<CR>')
                  end
               }
            )
         end,
      }
   }
}
