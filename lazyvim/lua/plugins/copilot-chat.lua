return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  cmd = "CopilotChat",
  opts = function()
    local user = vim.env.USER or "User"
    user = user:sub(1, 1):upper() .. user:sub(2)

    return {
      model = "claude-sonnet-4.5",
      auto_insert_mode = false,
      question_header = "  " .. user .. " ",
      answer_header = "  Copilot ",
      window = {
        width = 0.4,
      },
      chat_autocomplete = false,
    }
  end,
  keys = {
    { "<Leader>a", "", desc = "+Copilot", mode = { "n" } },
    {
      "<Leader>aa",
      function()
        require("CopilotChat").toggle()
      end,
      desc = "Toggle",
      mode = { "n" },
    },
    {
      "<Leader>am",
      function()
        vim.notify("Loading models...", vim.log.levels.INFO)
        require("CopilotChat").select_model()
      end,
      desc = "Select model",
      mode = { "n" },
    },
    {
      "<leader>ax",
      function()
        require("CopilotChat").reset()
      end,
      desc = "Clear",
      mode = { "n" },
    },
    {
      "<leader>aq",
      function()
        vim.ui.input({ prompt = "Quick Chat " }, function(input)
          if input ~= "" then
            require("CopilotChat").ask(input)
          end
        end)
      end,
      desc = "Quick Chat",
      mode = { "n" },
    },
    {
      "<leader>ap",
      function()
        require("CopilotChat").select_prompt()
      end,
      desc = "Prompt Actions",
      mode = { "n" },
    },
  },
  config = function(_, opts)
    local chat = require("CopilotChat")
    chat.setup(opts)
  end,
}
