return {
  "folke/flash.nvim",
  opts = {
    exclude = { "snacks_dashboard" },
    jump = { autojump = false },
    labels = "neioharstqfpluyzxkmgj;-",
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
    local Flash = require("flash")

    ---@param opts Flash.Format
    local function format_first_match(opts)
      -- always show first and second label
      return {
        { opts.match.label1, opts.hl_group },
        { opts.match.label2, opts.hl_group },
      }
    end

    local function format_second_match(opts)
      return {
        { opts.match.label2, opts.hl_group },
      }
    end

    local function action(match, state)
      state:hide()

      Flash.jump({
        search = {
          max_length = 0,
        },
        highlight = { matches = false },
        label = {
          after = { 0, 2 },
          format = format_second_match,
        },
        matcher = function(win)
          -- limit matches to the current label
          return vim.tbl_filter(function(m)
            return m.label == match.label and m.win == win
          end, state.results)
        end,
        labeler = function(matches)
          for _, m in ipairs(matches) do
            m.label = m.label2 -- use the second label
          end
        end,
      })
    end

    local function labeler(matches, state)
      local labels = state:labels()

      for m, match in ipairs(matches) do
        match.label1 = labels[math.floor((m - 1) / #labels) + 1]
        match.label2 = labels[(m - 1) % #labels + 1]
        match.label = match.label1
      end
    end

    return {
      {
        "<tab>",
        mode = { "n" },
        function()
          Flash.jump({
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
          Flash.jump({
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
          Flash.jump({
            search = {
              mode = "search",
              wrap = false,
              forward = true,
            },
            label = {
              after = false,
              before = { 0, 0 },
              uppercase = false,
              format = format_first_match,
            },
            pattern = [[\<]],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash forward to beginning of word",
      },
      {
        "W",
        mode = { "n" },
        function()
          Flash.jump({
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
          Flash.jump({
            search = {
              mode = "search",
              wrap = false,
              forward = false,
            },
            label = {
              after = false,
              before = { 0, 0 },
              uppercase = false,
              format = format_first_match,
            },
            pattern = [[\<]],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash backward to beginning of word",
      },
      {
        "B",
        mode = { "n" },
        function()
          Flash.jump({
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
