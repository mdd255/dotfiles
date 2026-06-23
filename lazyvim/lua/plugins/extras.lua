return {
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
        editMacro = "_",
        yankMacro = "_",
        deleteAllMacros = "_",
      },
    },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow.strategy["global"],
          vim = rainbow.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterOrange",
          "RainbowDelimiterYellow",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
          "RainbowDelimiterBlue",
          "RainbowDelimiterGreen",
        },
      }
    end,
  },
}
