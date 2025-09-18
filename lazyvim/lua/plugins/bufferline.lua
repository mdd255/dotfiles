local color = require("config/color")

return {
  "akinsho/bufferline.nvim",
  optional = true,
  opts = {
    options = {
      mode = "tabs",
      numbers = "none",
      close_command = false,
      right_mouse_command = false,
      left_mouse_command = false,
      middle_mouse_command = false,
      show_buffer_icons = false,
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = "slope",
      show_duplicate_prefix = false,
      always_show_bufferline = true,
    },
    highlights = {
      background = {
        bg = color.black,
        fg = color.gray,
      },
      fill = {
        bg = color.dark_gray,
      },
      separator = {
        fg = color.dark_gray,
        bg = color.black,
      },
      separator_selected = {
        fg = color.dark_gray,
        bg = color.black,
      },
      buffer_selected = {
        bg = color.black,
        fg = color.blue,
        bold = true,
        italic = false,
      },
      tab_close = {
        bg = color.white,
        fg = color.gray,
      },
    },
  },
  keys = false,
}
