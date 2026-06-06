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
        cmdline_popup = {
          position = { row = "40%", col = "50%" },
        },
        popupmenu = { scrollbar = false },
        notify = {
          replace = true,
          merge = true,
        },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },
}
