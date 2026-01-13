-- Autocommands are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local utils = require("config.utils")
local scroll_mark = require("config.scroll-mark")

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
    "sh",
  }

  local cursorline_blacklist = {
    "gitcommit",
    "snacks_dashboard",
  }

  local number_blacklist = {
    "snacks_dashboard",
    "snacks_terminal",
    "snacks_picker_list",
    "grug-far",
    "lazy",
    "DiffviewFiles",
    "text.kulala_ui",
    "json.kulala_ui",
    "dbui",
    "dbout",
    "noice",
    "blink-cmp-menu",
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

  if contains(number_blacklist, ft) then
    vim.opt_local.statuscolumn = ""
    vim.opt_local.signcolumn = "no"
  else
    scroll_mark.mark_scroll()
  end

  vim.opt_local.cursorline = not contains(cursorline_blacklist, ft)
end

-- Enable cursorline and relativenumber for specific filetypes
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, {
  callback = function()
    if not vim.g.diffview_active then
      setup_cursor_options()
    end
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  callback = function()
    if not vim.g.diffview_active then
      vim.opt_local.relativenumber = false
      vim.opt_local.cursorline = false
    end

    vim.api.nvim_buf_clear_namespace(0, scroll_mark.ns, 0, -1)
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- LSP disabled_client_format
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local function contains(list, item)
      for _, v in ipairs(list) do
        if v == item then
          return true
        end
      end
      return false
    end

    local disabled_client_format = {
      "ts_ls",
      "vtsls",
      "tsgo",
    }

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
    client.server_capabilities.documentHighlightProvider = false

    -- Disable auto-formatting for TypeScript language server
    if contains(disabled_client_format, client.name) then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "typescript",
  callback = function()
    local function console_log()
      local expr = "yeoconsole.log({<Esc>pa})<Esc>hh"

      return utils.create_marcro({
        pre_fn = utils.move_to_start_of_word,
        expr = expr,
      })
    end

    vim.keymap.set("n", "j", console_log, { buffer = true })
  end,
})
