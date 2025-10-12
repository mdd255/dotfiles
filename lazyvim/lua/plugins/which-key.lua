return {
  "folke/which-key.nvim",
  opts = {
    preset = "helix",
    defaults = {},
    plugins = {
      presets = {
        operator = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = false,
        g = false,
      },
    },
    icons = {
      mappings = false,
      separator = "",
    },
    spec = {
      { mode = { "n" } },
      { "t", group = " LSP" },
      { "f", group = " Find" },
      { "g", group = " Goto" },
      { "s", group = " Misc" },
      { "<Leader>", group = " 󱁐" },
      { "<Leader>d", group = "DBUI" },
      { "<Leader>g", group = "Neogit" },
      { "<Leader>s", group = "Diffview Open" },
      { "<Leader>c", group = "Macro" },
    },
    triggers = {
      { "t", mode = { "n" } },
      { "f", mode = { "n" } },
      { "g", mode = { "n" } },
      { "s", mode = { "n" } },
      { "<Leader>", mode = { "n" } },
    },
  },
  keys = false,
}
