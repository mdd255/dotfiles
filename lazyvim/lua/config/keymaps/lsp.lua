---@diagnostic disable: undefined-global
local utils = require("config.utils")
local map = utils.map
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
vim.keymap.set("n", "<Leader>k", lsp_functions.lsp_clients, { noremap = true, silent = true, desc = "LSP Clients" })

-- Diagnostics
map({
  { "tn", "<cmd>lua vim.diagnostic.goto_next()<Cr>", { modes = { "n" }, desc = "Go to next diagnostics" } },
  { "te", "<cmd>lua vim.diagnostic.goto_prev()<Cr>", { modes = { "n" }, desc = "Go to prev diagnostics" } },
  { "ta", "<cmd>lua Snacks.picker.diagnostics_buffer()<Cr>", { modes = { "n" }, desc = "LSP diagnostics" } },
  { "tA", "<cmd>lua Snacks.picker.diagnostics()<Cr>", { modes = { "n" }, desc = "Workspace LSP diagnostics" } },
})

-- LSP actions
map({
  { "t<Cr>", "<cmd>lua vim.lsp.buf.code_action()<Cr>", { modes = { "n" }, desc = "Code action" } },
  { "th", "<cmd>lua vim.lsp.buf.hover({border='rounded'})<Cr>", { modes = { "n" }, desc = "LSP hover" } },
  { "tr", "<cmd>lua vim.lsp.buf.rename()<Cr>", { modes = { "n" }, desc = "LSP rename" } },
})

-- Navigation via Snacks picker
map({
  { "tt", "<cmd>lua Snacks.picker.lsp_definitions()<Cr>", { modes = { "n" }, desc = "Go to definitions" } },
  { "ti", "<cmd>lua Snacks.picker.lsp_implementations()<Cr>", { modes = { "n" }, desc = "Go to implementations" } },
  { "td", "<cmd>lua Snacks.picker.lsp_type_definitions()<Cr>", { modes = { "n" }, desc = "Go to type definitions" } },
  { "tf", "<cmd>lua Snacks.picker.lsp_references()<Cr>", { modes = { "n" }, desc = "Go to references" } },
  { "ts", "<cmd>lua Snacks.picker.lsp_symbols()<Cr>", { modes = { "n" }, desc = "LSP symbols" } },
  { "tS", "<cmd>lua Snacks.picker.lsp_workspace_symbols()<Cr>", { modes = { "n" }, desc = "Workspace LSP symbols" } },
})
