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
    "2kabhishek/nerdy.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    cmd = "Nerdy",
    keys = {
      { "<Leader>t", "<cmd>Nerdy list<Cr>", desc = "Symbols" },
    },
    opts = {
      max_recents = 20,
      add_default_keybindings = false,
      copy_to_clipboard = false,
      copy_register = "+",
    },
  },
}
