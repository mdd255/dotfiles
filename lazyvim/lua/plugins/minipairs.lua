return {
  "nvim-mini/mini.pairs",
  opts = {
    modes = { insert = true, command = true, terminal = true },
    mappings = {
      [";h"] = { action = "open", pair = "<>" },
      [";n"] = { action = "open", pair = "()" },
      [";e"] = { action = "open", pair = "[]" },
      [";i"] = { action = "open", pair = "{}" },
      [";o"] = { action = "closeopen", pair = "''" },
      [";l"] = { action = "closeopen", pair = '""' },
      [";u"] = { action = "closeopen", pair = "``" },
    },
  },
}
