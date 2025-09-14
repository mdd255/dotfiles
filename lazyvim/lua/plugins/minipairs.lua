return {
  "echasnovski/mini.pairs",
  opts = {
    modes = { insert = true, command = false, terminal = false },
    mappings = {
      ["<C-n>"] = { action = "open", pair = "()" },
      ["<C-e>"] = { action = "open", pair = "[]" },
      ["<C-i>"] = { action = "open", pair = "{}" },
      ["<C-h>"] = { action = "open", pair = "<>" },
      ["<C-o>"] = { action = "closeopen", pair = "''" },
      ["<C-k>"] = { action = "closeopen", pair = '""' },
      --["<C-m>"] = { action = "closeopen", pair = "``" },
    },
  },
}
