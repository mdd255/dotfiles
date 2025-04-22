return {
   'lukas-reineke/indent-blankline.nvim',
   config = function()
      require('ibl').setup({
         indent = {
            char = '│',
         },
         exclude = {
            filetypes = {
               'dbout',
               'dashboard',
               'coc-explorer',
               'toggleterm',
               'help',
               'text',
               'lspinfo',
               'checkhealth',
               'leetcode.nvim'
            }
         }
      })
   end
}
