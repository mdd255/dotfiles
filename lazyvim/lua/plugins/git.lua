return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen" },
    keys = {
      { "<Leader>s", "<cmd>DiffviewOpen<Cr>", desc = "Diffview Open" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_formatter = "   <author> - <author_time:%R> [<summary>]",
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function nmap(lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set("n", lhs, rhs, opts)
        end

        nmap("gn", function()
          if vim.wo.diff then
            vim.cmd.normal({ "gn", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Go to next hunk" })

        nmap("ge", function()
          if vim.wo.diff then
            vim.cmd.normal({ "ge", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Go to prev hunk" })

        nmap("gq", gitsigns.reset_hunk, { desc = "Reset hunk" })
        nmap("gQ", gitsigns.reset_buffer, { desc = "Reset buffer" })

        nmap("gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
        nmap("gS", gitsigns.stage_buffer, { desc = "Stage buffer" })

        nmap("gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
        nmap("gP", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
      end,
    },
  },
  {
    "pwntester/octo.nvim",
    lazy = true,
    keys = {
      { "<Leader>o", "<cmd>Octo pr list<Cr>", desc = "PR list" },
      { "<LocalLeader>R", "<cmd>Octo pr reload<Cr>", desc = "Octo reload", ft = "octo" },
      { "<LocalLeader>dd", "<cmd>Octo pr draft<Cr>", desc = "mark as draft", ft = "octo" },
      { "<LocalLeader>dr", "<cmd>Octo pr ready<Cr>", desc = "mark as ready", ft = "octo" },
    },
    opts = {
      picker = "snacks",
      ssh_aliases = {
        ["git-hp"] = "github.com",
        ["git-abd"] = "github.com",
      },
    },
    config = function(_, opts)
      require("octo").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "octo" },
        callback = function(event)
          local wk = require("which-key")

          wk.add({
            { "<localleader>a", group = "+Octo assignee", buffer = event.buf },
            { "<localleader>v", group = "+Octo review", buffer = event.buf },
            { "<localleader>p", group = "+Octo PR", buffer = event.buf },
            { "<localleader>l", group = "+Octo label", buffer = event.buf },
            { "<localleader>i", group = "+Octo misc", buffer = event.buf },
            { "<localleader>g", group = "+Octo navigate", buffer = event.buf },
            { "<localleader>c", group = "+Octo comment", buffer = event.buf },
            { "<localleader>r", group = "+Octo reaction", buffer = event.buf },
            { "<localleader>d", group = "+Octo PR draft/ready", buffer = event.buf },
            { "<localleader>pr", group = "+Octo merge rebase", buffer = event.buf },
            { "<localleader>ps", group = "+Octo merge squash", buffer = event.buf },
          })
        end,
      })
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/snacks.nvim",
    },
    keys = {
      { "<Leader>g", "<cmd>Neogit<Cr>", desc = "Neogit" },
    },
    opts = {
      user_default_keymaps = false,
      integrations = {
        diffview = true,
        snacks = true,
      },
      mappings = {
        commit_editor = {
          ["q"] = "Close",
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
          ["<m-p>"] = "PrevMessage",
          ["<m-n>"] = "NextMessage",
          ["<m-r>"] = "ResetMessage",
        },
        commit_editor_I = {
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
        },
        rebase_editor = {
          ["p"] = "Pick",
          ["r"] = "Reword",
          ["e"] = "Edit",
          ["s"] = "Squash",
          ["f"] = "Fixup",
          ["x"] = "Execute",
          ["d"] = "Drop",
          ["b"] = "Break",
          ["q"] = "Close",
          ["<cr>"] = "OpenCommit",
          ["gk"] = "MoveUp",
          ["gj"] = "MoveDown",
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
          ["[c"] = "OpenOrScrollUp",
          ["]c"] = "OpenOrScrollDown",
        },
        rebase_editor_I = {
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
        },
        finder = {
          ["<cr>"] = "Select",
          ["<esc>"] = "Close",
          ["<tab>"] = "Next",
          ["<s-tab>"] = "Previous",
          ["<c-cr>"] = "InsertCompletion",
          ["<c-y>"] = "CopySelection",
          ["<space>"] = "MultiselectToggleNext",
          ["<s-Space>"] = "MultiselectTogglePrevious",
        },
        -- Setting any of these to `false` will disable the mapping.
        popup = {
          ["?"] = "HelpPopup",
          ["C"] = "CherryPickPopup",
          ["d"] = "DiffPopup",
          ["R"] = "RemotePopup",
          ["P"] = "PushPopup",
          ["X"] = "ResetPopup",
          ["Z"] = "StashPopup",
          ["i"] = "IgnorePopup",
          ["t"] = "TagPopup",
          ["b"] = "BranchPopup",
          ["B"] = "BisectPopup",
          ["w"] = "WorktreePopup",
          ["c"] = "CommitPopup",
          ["f"] = "FetchPopup",
          ["l"] = "LogPopup",
          ["x"] = "MergePopup",
          ["m"] = false,
          ["M"] = false,
          ["p"] = "PullPopup",
          ["r"] = "RebasePopup",
          ["v"] = "RevertPopup",
        },
        status = {
          ["n"] = "MoveDown",
          ["e"] = "MoveUp",
          ["q"] = "Close",
          ["I"] = "InitRepo",
          ["1"] = "Depth1",
          ["2"] = "Depth2",
          ["3"] = "Depth3",
          ["4"] = "Depth4",
          ["Q"] = "Command",
          ["<cr>"] = "Toggle",
          ["o"] = "GoToFile",
          ["za"] = false,
          ["x"] = "Discard",
          ["s"] = "Stage",
          ["S"] = "StageUnstaged",
          ["u"] = "Unstage",
          ["U"] = "UnstageStaged",
          ["K"] = "Untrack",
          ["y"] = "ShowRefs",
          ["$"] = "CommandHistory",
          ["Y"] = "YankSelected",
          ["R"] = "RefreshBuffer",
          ["<"] = "GoToPreviousHunkHeader",
          [">"] = "GoToNextHunkHeader",
          ["<tab>"] = "NextSection",
          ["<s-tab>"] = "PreviousSection",
        },
      },
      signs = {
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
    },
  },
}
