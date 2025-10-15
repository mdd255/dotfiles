return {
  "olimorris/codecompanion.nvim",
  opts = {
    memory = {
      opts = {
        chat = { enabled = true },
      },
    },
    strategies = {
      chat = {
        opts = {
          completion_provider = "blink",
        },
        adapter = {
          name = "copilot",
          model = "claude-sonnet-4",
        },
        keymaps = {
          send = {
            modes = { n = "<Cr>", i = "<C-Cr>" },
          },
          close = {
            modes = { n = { "<Esc>" }, i = "<C-q>" },
          },
          stop = {
            modes = { n = { "tq" } },
          },
          clear = {
            modes = { n = { "tl" } },
          },
          codeblock = {
            modes = { n = { "t<Cr>" } },
          },
          goto_file_under_cursor = {
            modes = { n = { "tt" } },
          },
          copilot_stats = {
            modes = { n = { "th" } },
          },
          memory = {
            modes = { n = { "tx" } },
          },
        },
      },
    },
  },
}
