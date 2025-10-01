vim.api.nvim_create_autocmd("InsertEnter", {
   pattern = "*",
   callback = function()
      vim.wo.relativenumber = false
      vim.cmd([[let @/='']])
   end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
   pattern = "*",
   callback = function()
      if vim.wo.number == true then
         vim.wo.relativenumber = true
      end
   end,
})

vim.api.nvim_create_autocmd("FileType", {
   pattern = "make",
   callback = function()
      vim.o.expandtab = false
   end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
   callback = function()
      vim.highlight.on_yank({
         higroup = "Visual",
         timeout = 500,
      })
   end,
})

vim.api.nvim_create_autocmd("LspAttach", {
   callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- nuke all LSP highlights
      client.server_capabilities.semanticTokensProvider = nil
      client.server_capabilities.documentHighlightProvider = false
   end,
})
