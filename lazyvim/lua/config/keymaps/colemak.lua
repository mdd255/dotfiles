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
  { "ah", "i<", { modes = { "o", "v" }, desc = "i<" } },
  { "an", "i(", { modes = { "o", "v" }, desc = "i(" } },
  { "ae", "i[", { modes = { "o", "v" }, desc = "i[" } },
  { "ai", "i{", { modes = { "o", "v" }, desc = "i{" } },
  { "ao", "i'", { modes = { "o", "v" }, desc = "i'" } },
  { "al", 'i"', { modes = { "o", "v" }, desc = 'i"' } },
  { "au", "i`", { modes = { "o", "v" }, desc = "i`" } },
  { "rh", "a<", { modes = { "o", "v" }, desc = "a<" } },
  { "rn", "a(", { modes = { "o", "v" }, desc = "a(" } },
  { "re", "a[", { modes = { "o", "v" }, desc = "a[" } },
  { "ri", "a{", { modes = { "o", "v" }, desc = "a{" } },
  { "ro", "a'", { modes = { "o", "v" }, desc = "a'" } },
  { "rl", 'a"', { modes = { "o", "v" }, desc = 'a"' } },
  { "ru", "a`", { modes = { "o", "v" }, desc = "a`" } },
})

