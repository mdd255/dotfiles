return {
  {

    "folke/noice.nvim",
    keys = {
      {
        "<c-n>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<c-n>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Forward",
        mode = { "i", "n", "s" },
      },
      {
        "<c-e>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-e>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Backward",
        mode = { "i", "n", "s" },
      },
    },
  },
  {
    "nacro90/numb.nvim",
    opts = {
      show_numbers = true,
      show_cursor_line = true,
      hide_relativenumbers = true,
      number_only = false,
      centered_peeking = true,
    },
  },
  {
    "petertriho/nvim-scrollbar",
    opts = {
      show_in_active_only = true,
      handler = {
        cursor = false,
        diagnostic = true,
        gitsigns = true,
        handle = false,
        search = false,
        ale = false,
      },
    },
  },
}
