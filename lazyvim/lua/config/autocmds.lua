local utils = require("config.utils")

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
    "",
    "snacks_dashboard",
    "snacks_terminal",
    "claudecode",
    "snacks_picker_list",
    "grug-far",
    "lazy",
    "mason",
    "DiffviewFiles",
    "text.kulala_ui",
    "json.kulala_ui",
    "noice",
    "blink-cmp-menu",
    "blink-cmp-documentation",
    "markdown.gh",
    "dbab_sidebar",
    "dbab_history",
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
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "typescript",
  callback = function()
    local function console_log()
      local expr = "yeoconsole.log({<Esc>pa})<Esc>hh"

      return utils.create_macro({
        pre_fn = utils.move_to_start_of_word,
        expr = expr,
      })
    end

    vim.keymap.set("n", "j", console_log, { buffer = true })
  end,
})
