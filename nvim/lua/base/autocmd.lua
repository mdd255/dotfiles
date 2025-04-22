vim.api.nvim_create_autocmd(
   'InsertEnter',
   {
      pattern = '*',
      callback = function()
         vim.wo.relativenumber = false
         vim.cmd([[let @/='']])
      end
   }
)

vim.api.nvim_create_autocmd(
   'InsertLeave',
   {
      pattern = '*',
      callback = function()
         if vim.wo.number == true then
            vim.wo.relativenumber = true
         end
      end
   }
)

vim.api.nvim_create_autocmd(
   'FileType',
   {
      pattern = 'make',
      callback = function()
         vim.o.expandtab = false
      end
   }
)

vim.api.nvim_create_autocmd(
   'FileType',
   {
      pattern = 'oil',
      callback = function()
         vim.wo.relativenumber = false
         vim.wo.number = false
      end
   }
)

vim.api.nvim_create_autocmd("TextYankPost", {
   callback = function()
      vim.highlight.on_yank({
         higroup = "Visual",
         timeout = 300,
      })
   end,
})
