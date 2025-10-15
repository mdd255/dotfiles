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
          super_diff = {
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
          next_chat = {
            modes = { n = { "tn" } },
          },
          previous_chat = {
            modes = { n = { "te" } },
          },
        },
      },
    },
  },
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion actions", mode = { "n", "v" } },
    { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion chat" },
    { "<leader>af", "<cmd>CodeCompanionChat Add<cr>", desc = "Add current file to chat", mode = { "n", "v" } },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "Prompt CodeCompanion inline", mode = { "n", "v" } },
    { "<leader>ar", "<cmd>CodeCompanionActions Review<cr>", desc = "Review selected code", mode = "v" },
    { "<leader>ae", "<cmd>CodeCompanionActions Explain<cr>", desc = "Explain selected code", mode = "v" },
    { "<leader>au", "<cmd>CodeCompanionActions UnitTests<cr>", desc = "Generate unit tests", mode = "v" },
    { "<leader>ad", "<cmd>CodeCompanionActions Debug<cr>", desc = "Debug code", mode = "v" },
  },
}
