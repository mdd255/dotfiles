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
    {
      "sphamba/smear-cursor.nvim",
      event = "VeryLazy",
      cond = vim.g.neovide == nil,
      opts = {
        hide_target_hack = true,
        cursor_color = "none",
      },
      specs = {
        -- disable mini.animate cursor
      },
    },
  },
}
