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

    local function format_first_match(opts)
      -- first label red, second label default (blue)
      return {
        { opts.match.label1, "FlashLabelFirst" },
        { opts.match.label2, opts.hl_group },
      }
    end

    local function format_second_match(opts)
      return {
        { opts.match.label2, opts.hl_group },
      }
    end

    local function create_action(offset)
      return function(match, state)
        state:hide()

        Flash.jump({
          search = {
            max_length = 0,
          },
          jump = offset and { offset = offset } or nil,
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
    end

    local action = create_action()
    local action_before = create_action(-1)

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
        "l",
        mode = { "n", "v", "o" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              wrap = false,
              forward = true,
              multi_window = true,
            },
            label = {
              after = { 0, 0 },
              before = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [=[[^[:alnum:]_ \t]\@<![^[:alnum:]_ \t]]=],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash backward to punctuation",
      },
      {
        "L",
        mode = { "n", "v", "o" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              wrap = false,
              forward = false,
              multi_window = true,
            },
            label = {
              after = { 0, 0 },
              before = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [=[[^[:alnum:]_ \t]\@<![^[:alnum:]_ \t]]=],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash backward to punctuation",
      },
      {
        "<Tab>",
        mode = { "n", "v", "o" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              wrap = false,
              forward = true,
              multi_window = true,
            },
            jump = { offset = -1 },
            label = {
              after = { 0, 0 },
              before = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [=[[^[:alnum:]_ \t]\@<![^[:alnum:]_ \t]]=],
            action = action_before,
            labeler = labeler,
          })
        end,
        desc = "Flash forward to before punctuation",
      },
      {
        "<S-Tab>",
        mode = { "n", "v", "o" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              wrap = false,
              forward = false,
              multi_window = true,
            },
            jump = { offset = -1 },
            label = {
              after = { 0, 0 },
              before = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [=[[^[:alnum:]_ \t]\@<![^[:alnum:]_ \t]]=],
            action = action_before,
            labeler = labeler,
          })
        end,
        desc = "Flash backward to before punctuation",
      },
      {
        "W",
        mode = { "n" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              wrap = false,
              forward = true,
              multi_window = false,
            },
            label = {
              after = { 0, 0 },
              before = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [[\w\>]],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash forward to end of word",
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
              multi_window = false,
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
        desc = "Flash forward to start of word",
      },
      {
        "w",
        mode = { "v", "o" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              wrap = false,
              forward = true,
              multi_window = false,
            },
            label = {
              after = { 0, 0 },
              before = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [[\w\>]],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash forward to end of word",
      },
      {
        "b",
        mode = { "n", "v", "o" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              wrap = false,
              forward = false,
              multi_window = false,
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
              wrap = false,
              forward = false,
              multi_window = false,
            },
            label = {
              after = { 0, 0 },
              before = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [[\w\>]],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash backward to end of word",
      },
    }
  end,
}
