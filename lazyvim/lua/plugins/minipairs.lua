return {
  "echasnovski/mini.pairs",
  opts = {
    modes = { insert = true, command = false, terminal = false },
    mappings = {
      ["<C-h>"] = { action = "open", pair = "<>" },
      ["<C-n>"] = { action = "open", pair = "()" },
      ["<C-e>"] = { action = "open", pair = "[]" },
      ["<C-o>"] = { action = "closeopen", pair = "''" },
      ["<C-j>"] = { action = "open", pair = "{}" },
      ["<C-l>"] = { action = "closeopen", pair = '""' },
      ["<C-u>"] = { action = "closeopen", pair = "``" },
    },
  },
}
