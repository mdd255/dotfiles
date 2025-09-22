return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "none",
      ["<Tab>"] = { "insert_next", "fallback" },
      ["<Cr>"] = { "accept", "fallback" },
      ["<S-Tab>"] = { "insert_prev", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down" },
      ["<C-u>"] = { "scroll_documentation_up" },
    },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      ghost_text = { enabled = true },
      menu = { enabled = true, scrollbar = false },
      documentation = { window = { scrollbar = false } },
      list = {
        selection = { preselect = true },
        cycle = { from_top = false },
        max_items = 8,
      },
    },

    signature = {
      window = { scrollbar = false },
    },
  },
}
