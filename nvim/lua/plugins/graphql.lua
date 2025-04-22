local map = require('base.utils').map

local keycodes = {
   run       = '<LEADER><LEADER>',
   variables = '<LEADER><CR>',
   headers   = '<LEADER><TAB>'
}

return {
   'thaiducdung255/denops-graphql.vim',
   keys = {
      { '<LEADER><LEADER>', '<CMD>GraphQLExecute<CR>' },
      { '<LEADER><CR>',     '<CMD>GraphQLEditHttpHeader<CR>' },
      { '<LEADER><TAB>',    '<CMD>GraphQLEdit<CR>' }
   },
   dependencies = {
      'vim-denops/denops.vim',
   },
   config = function()
      vim.notify('load graphql autocmd')
      vim.api.nvim_create_autocmd(
         'BufEnter',
         {
            pattern  = '*.graphql,*.gql',
            callback = function()
               vim.cmd(':LualineRenameTab graphql')
               map('n', keycodes.run, ':GraphQLExecute<CR>')
               map('n', keycodes.variables, ':GraphQLEditHttpHeader<CR>')
               map('n', keycodes.headers, [[:GraphQLEdit<CR>]])
            end

         }
      )
   end
}
