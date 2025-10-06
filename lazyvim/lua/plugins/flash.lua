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
        "w",
        mode = { "v" },
        function()
          require("flash").jump({
            search = {
              mode = "search",
              max_length = 0,
              wrap = false,
              forward = true,
              multi_windows = false,
            },
            pattern = [[\>]],
          })
        end,
        desc = "Flash forward to beginning of word",
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
        "b",
        mode = { "v" },
        function()
          require("flash").jump({
            search = {
              mode = "search",
              max_length = 0,
              multi_windows = false,
              wrap = false,
              forward = false,
            },
            pattern = [[\>]],
          })
        end,
        desc = "Flash backward to beginning of word",
      },
    }
  end,
}
