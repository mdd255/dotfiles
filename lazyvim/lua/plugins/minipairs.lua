return {
  "nvim-mini/mini.pairs",
  opts = {
    modes = { insert = true, command = true, terminal = true },
    mappings = {
      ["<C-h>"] = { action = "open", pair = "<>" },
      ["<C-n>"] = { action = "open", pair = "()" },
      ["<C-e>"] = { action = "open", pair = "[]" },
      ["<C-o>"] = { action = "closeopen", pair = "''" },
      ["<C-l>"] = { action = "open", pair = "{}" },
      ["<C-j>"] = { action = "closeopen", pair = '""' },
      ["<C-u>"] = { action = "closeopen", pair = "``" },
    },
  },
}
