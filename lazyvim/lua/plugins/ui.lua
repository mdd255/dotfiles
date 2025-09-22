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
    ops = {
      views = {
        popupmenu = { scrollbar = false },
      },
      presets = { lsp_doc_border = true },
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
      handlers = {
        cursor = false,
        diagnostic = true,
        gitsigns = true,
        handle = true,
        search = false,
        ale = false,
      },
      marks = {
        Error = { text = { "" } },
        Warn = { text = { "" } },
        Info = { text = { "" } },
        Hint = { text = { "" } },
        Misc = { text = { "" } },
        GitAdd = { text = "" },
        GitChange = { text = "" },
        GitDelete = { text = "" },
      },
      excluded_filetypes = {
        "snacks_picker_list",
      },
    },
  },
}
