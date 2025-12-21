return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "kristijanhusak/vim-dadbod-completion",
    },
    opts = {
      fuzzy = {
        sorts = {
          "exact",
          "score",
          "label",
          "sort_text",
        },
      },
      keymap = {
        preset = "none",
        ["<Tab>"] = { "insert_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "insert_prev", "snippet_backward", "fallback" },
        ["<Down>"] = { "insert_next", "fallback" },
        ["<Up>"] = { "insert_prev", "fallback" },
        ["<Cr>"] = { "accept", "fallback" },
        ["<C-n>"] = { "scroll_documentation_down", "fallback" },
        ["<C-e>"] = { "scroll_documentation_up", "fallback" },
        ["<C-o>"] = { "hide", "fallback" },
        ["<C-d>"] = { "show_documentation", "fallback" },
        ["<C-u>"] = { "hide_documentation", "fallback" },
        ["<C-i>"] = { "fallback" },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        ghost_text = { enabled = true },
        menu = {
          enabled = true,
          scrollbar = false,
          draw = {
            snippet_indicator = "",
          },
        },
        documentation = { window = { scrollbar = false }, auto_show = false },
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
        keymap = {
          preset = "inherit",
          ["<Cr>"] = { "accept_and_enter", "fallback" },
        },
        completion = {
          menu = { auto_show = true },
          ghost_text = { enabled = true },
        },
      },
    },
  },
}
