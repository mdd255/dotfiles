return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "kristijanhusak/vim-dadbod-completion",
    },
    opts = {
      keymap = {
        preset = "none",
        ["<Tab>"] = { "insert_next", "snippet_forward", "fallback" },
        ["<Cr>"] = { "accept", "fallback" },
        ["<S-Tab>"] = { "insert_prev", "snippet_backward", "fallback" },
        ["<C-n>"] = { "scroll_documentation_down", "fallback" },
        ["<C-e>"] = { "scroll_documentation_up", "fallback" },
        ["<Esc>"] = { "hide", "fallback" },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        ghost_text = { enabled = true },
        menu = { enabled = true, scrollbar = false },
        documentation = { window = { scrollbar = false } },
        list = {
          selection = { preselect = true, auto_insert = true },
          cycle = { from_top = false },
          max_items = 25,
        },
      },
      signature = {
        window = { scrollbar = false },
      },
      sources = {
        default = { "buffer", "lsp", "path", "snippets" },
        per_filetype = {
          sql = { "snippets", "dadbod", "buffer" },
          mysql = { "snippets", "dadbod", "buffer" },
          psql = { "snippets", "dadbod", "buffer" },
        },
        providers = {
          dadbod = { name = "DB", module = "vim_dadbod_completion.blink" },
        },
      },
      cmdline = {
        keymap = { preset = "inherit" },
        completion = {
          menu = { auto_show = true },
          ghost_text = { enabled = true },
        },
      },
    },
  },
}
