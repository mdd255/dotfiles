return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "none",

      ["<Tab>"] = { "insert_next" },
      ["<Cr>"] = { "accept" },
      ["<S-Tab>"] = { "insert_prev" },
      ["<C-n>"] = { "scroll_documentation_down" },
      ["<C-e>"] = { "scroll_documentation_up" },
    },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      ghost_text = { enabled = true },
      menu = { enabled = true },
      list = { selection = { preselect = true }, cycle = { from_top = false } },
    },
  },
}
