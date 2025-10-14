-- Enable cursorline only if filetype is not in the blacklist
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    local ft = vim.bo.filetype

    local relativenumber_whitelist = {
      typescript = true,
      php = true,
      javascript = true,
      java = true,
      lua = true,
      http = true,
      yaml = true,
    }

    local linenumber_blacklist = {}

    local cursorline_blacklist = {
      gitcommit = true,
      snacks_dashboard = true,
    }

    if linenumber_blacklist[ft] then
      vim.opt_local.number = false
    end

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

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})
