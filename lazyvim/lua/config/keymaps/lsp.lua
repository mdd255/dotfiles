---@diagnostic disable: undefined-global
local utils = require("config.utils")
local unmap = utils.unmap
local lsp_functions = require("config.lsp-functions")

-- Disable LazyVim default keymaps
unmap({
  -- Misc
  { "<Leader>up" },
  { "<Leader>uG" },
  { "gO" },
  -- LSP
  { "gra" },
  { "gri" },
  { "grn" },
  { "grr" },
  { "grt" },
  { "grx" },
})

-- LSP clients picker
vim.keymap.set("n", "<Leader>cs", lsp_functions.lsp_clients, { noremap = true, silent = true, desc = "LSP Clients" })
