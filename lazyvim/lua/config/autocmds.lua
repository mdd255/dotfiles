-- Autocommands are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function setup_cursor_options()
  local ft = vim.bo.filetype

  local relativenumber_whitelist = {
    typescript = true,
    php = true,
    javascript = true,
    java = true,
    lua = true,
    http = true,
    yaml = true,
    python = true,
  }

  local cursorline_blacklist = {
    gitcommit = true,
    snacks_dashboard = true,
  }

  local number_blacklist = {
    codecompanion = true,
    gitcommit = true,
    snacks_dashboard = true,
    snacks_terminal = true,
    snacks_picker_list = true,
    ["grug-far"] = true,
  }

  vim.opt_local.relativenumber = relativenumber_whitelist[ft] and not number_blacklist[ft] or false
  vim.opt_local.number = not number_blacklist[ft]
  vim.opt_local.cursorline = not cursorline_blacklist[ft]
end

-- Enable cursorline and relativenumber for specific filetypes
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    setup_cursor_options()
    vim.opt_local.cursorline = true
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.cursorline = false
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})
