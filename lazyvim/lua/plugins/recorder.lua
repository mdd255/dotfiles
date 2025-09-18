return {
  {
    "chrisgrieser/nvim-recorder",
    opts = {
      slots = { "a", "b" },
      clear = true,
      logLevel = vim.log.levels.OFF,
      mapping = {
        startStopRecording = "Q",
        playMacro = "q",
        editMacro = "<LEADER>cq",
      },
    },
  },
}
