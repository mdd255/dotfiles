---@diagnostic disable: undefined-global
local git = require("config.git-functions")

return {
  {
    "sindrets/diffview.nvim",
    event = { "BufRead", "BufNewFile" },
    lazy = false,
    keys = {
      { "so", "<cmd>DiffviewOpen<Cr>", desc = "Diffview open" },
      { "sf", git.get_current_file_history, desc = "Diffview current file history" },
      { "sa", git.git_diff_branch, desc = "Diff branch" },
      { "sr", git.git_pull, desc = "Git pull" },
      { "sR", git.git_push, desc = "Git push" },
      { "sc", git.create_pr, desc = "Create PR" },
    },

    config = function()
      local actions = require("diffview.actions")

      local function stage_all()
        actions.stage_all()
        vim.notify("Git: staged all files")
      end

      local opts = {
        enhanced_diff_hl = true,
        view = {
          default = {
            layout = "diff2_horizontal",
          },
        },
        file_panel = {
          listing_style = "list",
          win_config = {
            position = "bottom",
            height = 10,
          },
        },
        keymaps = {
          view = {
            { "n", "<Leader>q", git.close_diffview, { desc = "DiffviewClose" } },
            { "n", "-", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "S", stage_all, { desc = "Stage all" } },
            { "n", "gn", actions.next_conflict, { desc = "Goto next conflict" } },
            { "n", "ge", actions.prev_conflict, { desc = "Goto prev conflict" } },
            { "n", "gco", actions.conflict_choose_all("ours"), { desc = "Git conflict choose ours" } },
            { "n", "gct", actions.conflict_choose_all("theirs"), { desc = "Git conflict choose theirs" } },
            { "n", "gca", actions.conflict_choose_all("all"), { desc = "Git conflict choose all" } },
            { "n", "gcn", actions.conflict_choose_all("none"), { desc = "Git conflict choose none" } },
            { "n", "gcb", actions.conflict_choose_all("base"), { desc = "Git conflict choose base" } },
            { "n", "s<Cr>", git.git_commit, { desc = "Git commit" } },
            { "n", "sA", git.git_commit_amend, { desc = "Git commit amend" } },
          },
          file_panel = {
            { "n", "-", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "<Leader>q", git.close_diffview, { desc = "DiffviewClose" } },
            { "n", "<Esc>", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "S", stage_all, { desc = "Stage all" } },
            { "n", "s<Cr>", git.git_commit, { desc = "Git commit" } },
            { "n", "sA", git.git_commit_amend, { desc = "Git commit amend" } },
          },
          file_history_panel = {
            { "n", "<Leader>q", git.close_diffview, { desc = "DiffviewClose" } },
            { "n", "-", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "<Esc>", actions.toggle_files, { desc = "Toggle file explorer" } },
          },
        },
      }

      -- Setup autocmd to disable line numbers when Diffview opens
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "DiffviewFiles", "DiffviewFileHistory" },
        callback = function()
          vim.defer_fn(function()
            vim.g.diffview_active = true

            local visible_wins = vim.api.nvim_tabpage_list_wins(0)

            -- Disable for all visible windows in current tabpage
            for _, win in ipairs(visible_wins) do
              vim.api.nvim_set_option_value("number", false, { win = win })
              vim.api.nvim_set_option_value("relativenumber", false, { win = win })
              vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
              vim.api.nvim_set_option_value("statuscolumn", "", { win = win })
            end
          end, 100)
        end,
      })

      require("diffview").setup(opts)
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    opts = {
      current_line_blame = true,
      current_line_blame_formatter = "   <author> - <author_time:%R> [<summary>]",
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "│" },
        topdelete = { text = "│" },
        changedelete = { text = "│" },
        untracked = { text = "┆" },
      },
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

        nmap("gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
        nmap("gP", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
      end,
    },
  },
}
