return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "fang2hou/blink-copilot",
      "kristijanhusak/vim-dadbod-completion",
    },
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
          max_items = 25,
        },
      },
      signature = {
        window = { scrollbar = false },
      },
      sources = {
        default = { "buffer", "copilot", "lsp", "path", "snippets" },
        per_filetype = {
          sql = { "snippets", "dadbod", "buffer" },
          mysql = { "snippets", "dadbod", "buffer" },
          psql = { "snippets", "dadbod", "buffer" },
          ["copilot-chat"] = { "path", "buffer" },
        },
        providers = {
          dadbod = { name = "DB", module = "vim_dadbod_completion.blink" },
          copilot = { name = "copilot", module = "blink-copilot", score_offset = 100, async = true },
        },
      },
    },
  },
}
