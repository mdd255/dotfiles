return {
  "folke/flash.nvim",
  opts = {
    jump = { autojump = true },
    labels = "neioharstdqwfpluyzxcvkmbgj;NEIOHARSTDQWFPLUYZXCVKMBGJ1234567890!@#$%^&*()_+=.,",
    modes = {
      char = {
        keys = {},
      },
    },
    label = {
      uppercase = false,
      current = false,
      before = true,
      after = false,
    },
    search = {
      multi_window = false,
    },
  },
  keys = function()
    return {
      {
        "<tab>",
        mode = { "n", "v", "o" },
        function()
          require("flash").jump({
            multi_windows = false,
            search = { mode = "search", max_length = 20 },
          })
        end,
        desc = "Flash any forward",
      },
      {
        "'",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            pattern = [=[[([{<'"`]]=],
            search = { mode = "search" },
            label = { after = false, before = true, current = false },
          })
        end,
        desc = "Flash open bracket",
      },
    }
  end,
}
