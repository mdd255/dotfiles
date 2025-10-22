-- Autocommands are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function setup_cursor_options()
  local ft = vim.bo.filetype

  local relativenumber_whitelist = {
    "typescript",
    "php",
    "javascript",
    "java",
    "lua",
    "http",
    "yaml",
    "python",
  }

  local cursorline_blacklist = {
    "gitcommit",
    "snacks_dashboard",
  }

  local number_blacklist = {
    "codecompanion",
    "gitcommit",
    "snacks_dashboard",
    "snacks_terminal",
    "snacks_picker_list",
    "grug-far",
    "lazy",
  }

  local function contains(list, item)
    for _, v in ipairs(list) do
      if v == item then
        return true
      end
    end
    return false
  end

  vim.opt_local.relativenumber = contains(relativenumber_whitelist, ft) and not contains(number_blacklist, ft) or false
  vim.opt_local.number = not contains(number_blacklist, ft)
  vim.opt_local.cursorline = not contains(cursorline_blacklist, ft)
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
