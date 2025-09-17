return {
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
}
