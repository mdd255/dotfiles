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
}
