return {
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
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    config = function()
      require("colorizer").setup({
        user_default_options = {
          names = false,
          mode = "virtualtext",
          virtualtext_inline = "after",
          virtualtext = "",
        },
      })
    end,
  },
  {
    "chrisgrieser/nvim-recorder",
    lazy = true,
    opts = {
      slots = { "a", "b" },
      clear = true,
      logLevel = vim.log.levels.OFF,
      mapping = {
        startStopRecording = "Q",
        playMacro = "q",
        editMacro = "<Leader>cq",
      },
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = false,
  },
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
  },
}
