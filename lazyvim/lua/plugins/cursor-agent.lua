return {
  "bka9/cursor.nvim",
  event = "VeryLazy",
  keys = {
    { "<C-o>", "<cmd>CursorAgentFocus<cr>", desc = "Cursor Agent", mode = { "n", "x" } },
  },
  opts = {
    -- base command
    cmd = "cursor-agent",

    -- cursor-agent runs in interactive mode by default

    -- map of parameter -> value, will be converted to flags using --kebab-case
    -- refer to https://docs.cursor.com/en/cli/reference/parameters
    parameters = {
      -- project_dir = vim.loop.cwd(),
      -- model = "sonnet",
      -- api_key = os.getenv("CURSOR_API_KEY"),
    },

    -- extra raw args appended after parameters
    extra_args = {},

    -- window options
    window = {
      type = "current", -- "float" | "horizontal" | "vertical" | "current"
      width = 1,
      border = "rounded",
      position = "right",
      focus = true,
    },

    -- start terminal in insert mode
    start_in_insert = true,

    -- close terminal automatically when process exits
    auto_close_on_exit = true,

    -- disable default keymaps (set to false to enable)
    disable_default_keymaps = true,
  },
  config = function(_, opts)
    require("cursor_agent").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "cursor-agent",
      callback = function()
        -- Map ESC to exit terminal insert mode (normal mode)
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = true })
      end,
    })
  end,
}
