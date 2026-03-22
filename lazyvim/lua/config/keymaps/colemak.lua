---@diagnostic disable: undefined-global
local utils = require("config.utils")
local map = utils.map

-- Colemak-specific keymaps
map({
  -- Colemak navigation
  { "n", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down" } },
  { "e", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up" } },
  { "i", "l", { desc = "Right" } },
  { "k", "i", { desc = "Insert mode" } },
  { "K", "I", { desc = "Insert at beginning of line" } },

  -- Colemak window nav (reuses same keys but with Leader)
  { "<Leader>n", "<C-w>j", { desc = "To lower win" } },
  { "<Leader>e", "<C-w>k", { desc = "To upper win" } },
  { "<Leader>i", "<C-w>l", { desc = "To right win" } },

  -- Bracket mappings for Colemak
  { "h", "i<", { modes = { "o" }, desc = "i<" } },
  { "n", "i(", { modes = { "o" }, desc = "i(" } },
  { "e", "i[", { modes = { "o" }, desc = "i[" } },
  { "i", "i{", { modes = { "o" }, desc = "i{" } },
  { "o", "i'", { modes = { "o" }, desc = "i'" } },
  { "l", 'i"', { modes = { "o" }, desc = 'i"' } },
  { "u", "i`", { modes = { "o" }, desc = "i`" } },
  { "H", "a<", { modes = { "o" }, desc = "a<" } },
  { "N", "a(", { modes = { "o" }, desc = "a(" } },
  { "E", "a[", { modes = { "o" }, desc = "a[" } },
  { "I", "a{", { modes = { "o" }, desc = "a{" } },
  { "O", "a'", { modes = { "o" }, desc = "a'" } },
  { "L", 'a"', { modes = { "o" }, desc = 'a"' } },
  { "U", "a`", { modes = { "o" }, desc = "a`" } },
})
