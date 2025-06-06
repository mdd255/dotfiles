return {
  "akinsho/bufferline.nvim",
  optional = true,
  opts = {
    options = {
      modes = "tabs",
      numbers = "none",
      close_command = false,
      right_mouse_command = false,
      left_mouse_command = false,
      middle_mouse_command = false,
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = "slope",
    },
  },
  keys = {
    { "<leader>bp", false },
    { "<leader>bP", false },
    { "<leader>br", false },
    { "<leader>bl", false },
    { "[b", false },
    { "]b", false },
    { "<H>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<I>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "<C-h>", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "<C-i>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
  },
}
