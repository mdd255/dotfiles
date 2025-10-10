-- Enable cursorline only if filetype is not in the blacklist
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    local ft = vim.bo.filetype

    local relativenumber_whitelist = {
      typescipt = true,
      php = true,
      javascript = true,
      java = true,
      lua = true,
    }

    local cursorline_blacklist = {
      gitcommit = true,
      snacks_dashboard = true,
    }

    if relativenumber_whitelist[ft] then
      vim.opt_local.relativenumber = true
    end

    if not cursorline_blacklist[ft] then
      vim.opt_local.cursorline = true
    end
  end,
})

-- Always disable on leave
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  callback = function()
    vim.opt_local.cursorline = false
    vim.opt_local.relativenumber = false
  end,
})

-- disable
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
    client.server_capabilities.documentHighlightProvider = false
  end,
})

-- neovide only
if vim.g.neovide then
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    callback = function()
      local project_name = vim.fn.getcwd():gsub("^.*/", "")
      vim.o.titlestring = "vi:" .. project_name
    end,
  })
end
