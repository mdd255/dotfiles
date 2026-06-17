local supermaven_ft_blacklist = {
  snacks_input = true,
  sql = true,
}

return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "supermaven-inc/supermaven-nvim",
      -- zerochae/dbab.nvim provides blink_dbab completion source (autocomplete).
      -- mdd255/dbab.nvim (plugins/dbab.lua) is the full DB client UI. Different repos, same short name — not a conflict.
      "zerochae/dbab.nvim",
      {
        "Huijiro/blink-cmp-supermaven",
        config = function()
          require("supermaven-nvim").setup({
            condition = function()
              return supermaven_ft_blacklist[vim.bo.filetype] == true
            end,
          })
        end,
      },
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
        ["<Tab>"] = { "insert_next", "fallback" },
        ["<S-Tab>"] = { "insert_prev", "fallback" },
        ["<Down>"] = { "insert_next", "fallback" },
        ["<Up>"] = { "insert_prev", "fallback" },
        ["<Cr>"] = { "accept", "fallback" },
        ["<C-n>"] = { "snippet_forward", "scroll_documentation_down", "fallback" },
        ["<C-e>"] = { "snippet_backward", "scroll_documentation_up", "fallback" },
        ["<C-o>"] = { "hide", "fallback" },
        ["<C-d>"] = { "show_documentation", "fallback" },
        ["<C-u>"] = { "hide_documentation", "fallback" },
        ["<C-i>"] = { "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        ghost_text = { enabled = true },
        menu = {
          enabled = true,
          scrollbar = false,
          draw = {
            snippet_indicator = "󰨸",
          },
        },
        documentation = { window = { scrollbar = false }, auto_show = true },
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
        default = { "snippets", "lsp", "buffer", "path", "supermaven" },
        per_filetype = {
          sql = { "snippets", "dbab", "buffer" },
          mysql = { "snippets", "dbab", "buffer" },
          psql = { "snippets", "dbab", "buffer" },
          snacks_input = { "snippets", "buffer" },
        },
        providers = {
          dbab = { name = "DA", module = "blink_dbab" },
          supermaven = {
            name = "supermaven",
            module = "blink-cmp-supermaven",
            async = true,
          },
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
