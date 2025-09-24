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
      separator = "", -- symbol used between a key and it's label
    },
  },
  keys = false,
}
