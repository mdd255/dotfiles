return {
  "folke/flash.nvim",
  event = "VeryLazy",
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

    local function labeler(matches, state)
      local labels = state:labels()

      for m, match in ipairs(matches) do
        match.label1 = labels[math.floor((m - 1) / #labels) + 1]
        match.label2 = labels[(m - 1) % #labels + 1]
        match.label = match.label1
      end
    end

    local function create_text_object_action(op, text_obj)
      return function(match, state)
        state:hide()

        Flash.jump({
          search = { max_length = 0 },
          highlight = { matches = false },
          label = {
            after = { 0, 2 },
            format = format_second_match,
          },
          matcher = function(win)
            return vim.tbl_filter(function(m)
              return m.label == match.label and m.win == win
            end, state.results)
          end,
          labeler = function(matches)
            for _, m in ipairs(matches) do
              m.label = m.label2
            end
          end,
          action = function(match2)
            local original_win = vim.api.nvim_get_current_win()
            local original_pos = vim.api.nvim_win_get_cursor(original_win)

            vim.api.nvim_win_call(match2.win, function()
              vim.api.nvim_win_set_cursor(match2.win, match2.pos)
              local line = vim.fn.getline(".")
              local col = vim.fn.col(".")
              local char = line:sub(col, col)

              local motion_map = {
                ["("] = op .. text_obj .. ")",
                ["["] = op .. text_obj .. "]",
                ["{"] = op .. text_obj .. "}",
                ["<"] = op .. text_obj .. ">",
                ['"'] = op .. text_obj .. '"',
                ["'"] = op .. text_obj .. "'",
                ["`"] = op .. text_obj .. "`",
              }

              local motion = motion_map[char] or (op .. text_obj .. "w")
              vim.cmd("normal! " .. motion)

              if op == "c" then
                vim.cmd("startinsert")
              end
            end)

            if op == "d" or op == "y" then
              vim.api.nvim_set_current_win(original_win)
              vim.api.nvim_win_set_cursor(original_win, original_pos)
            end
          end,
        })
      end
    end

    return {
      {
        "<Tab>",
        mode = { "n", "v", "o" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              forward = true,
              multi_window = true,
            },
            jump = { offset = -1 },
            label = {
              before = false,
              after = true,
              current = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [=[[(\[{<"'.,|:]]=],
            action = action,
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
              forward = false,
              multi_window = true,
            },
            label = {
              before = false,
              after = true,
              current = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [=[[)\]}>]]=],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash backward to closing brace",
      },
      {
        "l",
        mode = { "n" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              multi_window = false,
            },
            label = {
              after = true,
              before = false,
              current = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [[\<\w]],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash forward to start of word",
      },
      {
        "L",
        mode = { "n", "v", "o" },
        function()
          Flash.jump({
            search = {
              mode = "search",
              multi_window = false,
            },
            label = {
              after = true,
              before = false,
              current = false,
              uppercase = false,
              format = format_first_match,
            },
            pattern = [[\w\>]],
            action = action,
            labeler = labeler,
          })
        end,
        desc = "Flash backward to beginning of word",
      },
      {
        "dn",
        mode = "n",
        function()
          Flash.jump({
            pattern = [=[[([{<"'`]]=],
            search = { mode = "search", multi_window = false },
            label = {
              after = true,
              before = false,
              current = false,
              format = format_first_match,
            },
            action = create_text_object_action("d", "i"),
            labeler = labeler,
          })
        end,
        desc = "Flash delete inside",
      },
      {
        "de",
        mode = "n",
        function()
          Flash.jump({
            pattern = [=[[([{<"'`]]=],
            search = { mode = "search" },
            label = {
              after = true,
              before = false,
              current = false,
              format = format_first_match,
            },
            action = create_text_object_action("d", "a"),
            labeler = labeler,
          })
        end,
        desc = "Flash delete around",
      },
      {
        "cn",
        mode = "n",
        function()
          Flash.jump({
            pattern = [=[[([{<"'`]]=],
            search = { mode = "search" },
            label = {
              after = true,
              before = false,
              current = false,
              format = format_first_match,
            },
            action = create_text_object_action("c", "i"),
            labeler = labeler,
          })
        end,
        desc = "Flash change inside",
      },
      {
        "ce",
        mode = "n",
        function()
          Flash.jump({
            pattern = [=[[([{<"'`]]=],
            search = { mode = "search" },
            label = {
              after = true,
              before = false,
              current = false,
              format = format_first_match,
            },
            action = create_text_object_action("c", "a"),
            labeler = labeler,
          })
        end,
        desc = "Flash change around",
      },
      {
        "yn",
        mode = "n",
        function()
          Flash.jump({
            pattern = [=[[([{<"'`]]=],
            search = { mode = "search" },
            label = {
              after = true,
              before = false,
              current = false,
              format = format_first_match,
            },
            action = create_text_object_action("y", "i"),
            labeler = labeler,
          })
        end,
        desc = "Flash yank inside",
      },
      {
        "ye",
        mode = "n",
        function()
          Flash.jump({
            pattern = [=[[([{<"'`]]=],
            search = { mode = "search" },
            label = {
              after = true,
              before = false,
              current = false,
              format = format_first_match,
            },
            action = create_text_object_action("y", "a"),
            labeler = labeler,
          })
        end,
        desc = "Flash yank around",
      },
    }
  end,
}
