return {
  "folke/flash.nvim",
  opts = {
    exclude = { "snacks_dashboard" },
    jump = { autojump = false },
    labels = "neioharstqfpluyzxkmgj;-NEIOHARSTQFLUYZXVKMBGJ1234567890!@#$%^&*()_+",
    modes = {
      char = {
        keys = {},
      },
    },
    label = {
      uppercase = false,
      current = true,
      before = false,
      after = true,
    },
    search = {
      multi_window = false,
    },
  },
  keys = function()
    return {
      {
        "<tab>",
        mode = { "n" },
        function()
          require("flash").jump({
            search = {
              mode = "char",
              max_length = 1,
              wrap = false,
              forward = true,
              multi_windows = false,
            },
          })
        end,
        desc = "Flash f",
      },
      {
        "<s-tab>",
        mode = { "n" },
        function()
          require("flash").jump({
            search = {
              mode = "char",
              forward = false,
              wrap = false,
              multi_windows = false,
              max_length = 1,
            },
          })
        end,
        desc = "Flash F",
      },
      {
        "w",
        mode = { "n" },
        function()
          require("flash").jump({
            search = {
              mode = "search",
              max_length = 0,
              wrap = false,
              forward = true,
              multi_windows = false,
            },
            pattern = [[\<]],
          })
        end,
        desc = "Flash forward to beginning of word",
      },
      {
        "W",
        mode = { "n" },
        function()
          require("flash").jump({
            search = {
              mode = "search",
              max_length = 0,
              wrap = false,
              forward = true,
              multi_windows = false,
            },
            pattern = [[\w\>]],
          })
        end,
        desc = "Flash forward to end of word",
      },
      {
        "b",
        mode = { "n" },
        function()
          require("flash").jump({
            search = {
              mode = "search",
              max_length = 0,
              multi_windows = false,
              wrap = false,
              forward = false,
            },
            pattern = [[\<]],
          })
        end,
        desc = "Flash backward to beginning of word",
      },
      {
        "B",
        mode = { "n" },
        function()
          require("flash").jump({
            search = {
              mode = "search",
              max_length = 0,
              multi_windows = false,
              wrap = false,
              forward = false,
            },
            pattern = [[\w\>]],
          })
        end,
        desc = "Flash backward to end of word",
      },
    }
  end,
}
