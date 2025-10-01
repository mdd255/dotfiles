return {
  {
    "folke/noice.nvim",
    keys = {
      { "<Leader>sn", false },
      { "<Leader>sna", false },
      { "<Leader>snd", false },
      { "<Leader>snh", false },
      { "<Leader>snl", false },
      { "<Leader>snt", false },
      {
        "<c-n>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<C-n>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Forward",
        mode = { "n", "i" },
      },
      {
        "<c-e>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<C-e>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Backward",
        mode = { "n", "i" },
      },
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
      },
      messages = {
        enabled = true,
      },
      popupmenu = {
        enabled = true,
      },
      views = {
        popupmenu = { scrollbar = false },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
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
        "lazy",
      },
    },
  },
}
