---@diagnostic disable: undefined-global
local git = require("config.git-functions")

return {
  {
    "sindrets/diffview.nvim",
    lazy = false,
    keys = {
      { "gdi", "<cmd>DiffviewOpen<Cr>", desc = "Diffview open" },
      { "gpr", "<cmd>lua Snacks.picker.gh_pr({ search = 'user-review-requested:@me' })<Cr>", desc = "Github PRs" },
      { "gdf", git.get_current_file_history, desc = "Diffview current file history" },
      { "gdb", git.git_diff_branch, desc = "Diff branch" },
      { "gpl", git.git_pull, desc = "Git pull" },
      { "gpu", git.git_push, desc = "Git push" },
      { "gpc", git.create_pr, desc = "Create PR" },
      { "gpa", git.gh_switch_account, desc = "Switch GitHub account" },
      { "gss", git.git_stash_push, desc = "Git stash push" },
      { "gsp", "<cmd>lua Snacks.picker.git_stash()<Cr>", desc = "Git stash" },
      { "gsd", git.git_stash_drop, desc = "Git stash drop" },
      { "gaq", git.git_restore_staged, desc = "Git restore --staged" },
      { "grh", git.git_reset_hard, desc = "Git reset --hard" },
      { "grs", git.git_reset_soft, desc = "Git reset --soft" },
      { "gcm", git.git_commit, desc = "Git commit" },
      { "gca", git.git_commit_amend, desc = "Git commit amend" },
      { "gst", git.git_status, desc = "Git status" },
      { "gad", git.git_add_all, desc = "Git add all" },
      { "gbc", git.git_checkout_branch, desc = "Git checkout branch" },
      { "gbn", git.git_checkout_new_branch, desc = "Git checkout new branch" },
      { "gbd", git.git_delete_branch, desc = "Git delete branch" },
      { "gcp", git.git_cherry_pick, desc = "Git cherry-pick" },
      { "gcd", git.git_cherry_pick_abort, desc = "Git cherry-pick abort" },
      { "grv", git.git_revert, desc = "Git revert" },
      { "glo", "<cmd>DiffviewFileHistory<Cr>", desc = "Git log" },
      { "gpf", "<cmd>lua Snacks.gitbrowse()<Cr>", desc = "Git open file in browser" },
    },

    config = function()
      local actions = require("diffview.actions")

      local function stage_all()
        actions.stage_all()
        vim.notify("Git: staged all files")
      end

      local function update_diffview_progress()
        local view = require("diffview.lib").get_current_view()

        if not view or not view.panel then
          return
        end

        local files = view.panel:ordered_file_list()
        local total = #files
        if total == 0 then
          return
        end

        local cur = view.panel.cur_file
        if cur then
          for i, f in ipairs(files) do
            if f == cur or (f.path and cur.path and f.path == cur.path) then
              vim.g.diffview_progress = "[" .. i .. "/" .. total .. "]"
              return
            end
          end
        end

        vim.g.diffview_progress = "[1/" .. total .. "]"
      end

      local opts = {
        enhanced_diff_hl = true,
        hooks = {
          view_opened = function()
            vim.g.diffview_tab = vim.api.nvim_tabpage_get_number(0)

            vim.defer_fn(function()
              vim.g.diffview_active = true
              update_diffview_progress()

              for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                vim.api.nvim_set_option_value("number", false, { win = win })
                vim.api.nvim_set_option_value("relativenumber", false, { win = win })
                vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
                vim.api.nvim_set_option_value("statuscolumn", "", { win = win })
              end
            end, 200)
          end,

          view_post_layout = function()
            vim.g.diffview_tab = vim.g.diffview_tab or vim.api.nvim_tabpage_get_number(0)
            vim.schedule(update_diffview_progress)
          end,

          diff_buf_win_enter = function()
            vim.schedule(update_diffview_progress)
          end,

          view_closed = function()
            vim.g.diffview_active = false
            vim.g.diffview_progress = nil
            vim.g.diffview_tab = nil
          end,
        },
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

      require("diffview").setup(opts)
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
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

        nmap("gi", gitsigns.preview_hunk, { desc = "Preview hunk" })
        nmap("gI", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
      end,
    },
  },
}
