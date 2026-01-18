---@diagnostic disable: undefined-global
local utils = require("config.utils")
local unmap = utils.unmap

-- Disable LazyVim default keymaps
unmap({
  -- Misc
  { "<Leader>up" },
  { "<Leader>w0" },
  { "gO" },
  -- LSP
  { "gra" },
  { "gri" },
  { "grn" },
  { "grr" },
  { "grt" },
})

