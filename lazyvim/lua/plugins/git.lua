local function get_current_file_history()
  local current_file = vim.fn.expand("%:.")
  vim.cmd("DiffviewFileHistory " .. current_file)
end

local function git_pull()
  vim.notify("Pulling...", vim.log.levels.INFO)

  vim.system({ "git", "pull" }, {}, function(pull_result)
    vim.schedule(function()
      if pull_result.code == 0 then
        vim.notify("Pull successful", vim.log.levels.INFO)
      else
        vim.notify("Pull failed: " .. (pull_result.stderr or "unknown error"), vim.log.levels.ERROR)
      end
    end)
  end)
end

local function close_diffview()
  vim.cmd("DiffviewClose")
  vim.g.diffview_active = false
end

local function git_commit()
  local branch = vim.b.gitsigns_head or vim.fn.system("git branch --show-current"):gsub("\n", "")

  local function on_push_done(push_result)
    vim.schedule(function()
      if push_result.code == 0 then
        vim.notify("Pushed to: " .. branch, vim.log.levels.INFO)
      else
        vim.notify("Failed to push: " .. (push_result.stderr or "unknown error"), vim.log.levels.ERROR)
      end
    end)
  end

  local function on_commit_done(commit_result)
    vim.schedule(function()
      if commit_result.code ~= 0 then
        vim.notify("Commit failed: " .. (commit_result.stderr or "unknown error"), vim.log.levels.ERROR)
        return
      end
      vim.notify("Committed, pushing to: " .. branch .. "...", vim.log.levels.INFO)
      vim.system({ "git", "push" }, {}, on_push_done)
    end)
  end

  local function on_input(msg)
    if msg and msg ~= "" then
      vim.schedule(function()
        close_diffview()
        vim.system({ "git", "commit", "-m", msg }, {}, on_commit_done)
      end)
    end
  end

  require("snacks").input({ prompt = "Commit to: " .. branch .. " :" }, on_input)
end

local function git_diff_branch()
  local function on_branch_selected(selected)
    if selected then
      vim.cmd("DiffviewOpen " .. selected)
    end
  end

  local function on_branches_fetched(branch_result)
    vim.schedule(function()
      if branch_result.code ~= 0 then
        vim.notify("Failed to get branches", vim.log.levels.ERROR)
        return
      end

      local branches = {}
      for line in branch_result.stdout:gmatch("[^\r\n]+") do
        local branch = line:gsub("^%s*%*?%s*", ""):gsub("^remotes/origin/", "")
        if branch ~= "" and not branch:match("HEAD") then
          table.insert(branches, branch)
        end
      end

      vim.ui.select(branches, { prompt = "Select branch to diff: " }, on_branch_selected)
    end)
  end

  vim.system({ "git", "branch", "-a" }, {}, on_branches_fetched)
end

return {
  {
    "sindrets/diffview.nvim",
    lazy = false,
    keys = {
      { "so", "<cmd>DiffviewOpen<Cr>", desc = "Diffview open" },
      { "sf", get_current_file_history, desc = "Diffview current file history" },
      { "sa", git_diff_branch, desc = "Diff branch" },
      { "sr", git_pull, desc = "Git pull" },
    },

    config = function()
      local actions = require("diffview.actions")

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
            { "n", "<Leader>q", close_diffview, { desc = "DiffviewClose" } },
            { "n", "-", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "S", actions.stage_all, { desc = "Stage all" } },
            { "n", "gn", actions.next_conflict, { desc = "Goto next conflict" } },
            { "n", "ge", actions.prev_conflict, { desc = "Goto prev conflict" } },
            { "n", "gco", actions.conflict_choose_all("ours"), { desc = "Git conflict choose ours" } },
            { "n", "gct", actions.conflict_choose_all("theirs"), { desc = "Git conflict choose theirs" } },
            { "n", "gca", actions.conflict_choose_all("all"), { desc = "Git conflict choose all" } },
            { "n", "gcn", actions.conflict_choose_all("none"), { desc = "Git conflict choose none" } },
            { "n", "gcb", actions.conflict_choose_all("base"), { desc = "Git conflict choose base" } },
            { "n", "gca", actions.prev_conflict, { desc = "Toggle file explorer" } },
            { "n", "s<Cr>", git_commit, { desc = "Git commit" } },
          },
          file_panel = {
            { "n", "<Leader>q", close_diffview, { desc = "DiffviewClose" } },
            { "n", "-", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "<Esc>", actions.toggle_files, { desc = "Toggle file explorer" } },
          },
          file_history_panel = {
            { "n", "<Leader>q", close_diffview, { desc = "DiffviewClose" } },
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
            end
          end, 100)
        end,
      })

      require("diffview").setup(opts)
    end,
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

        nmap("gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
        nmap("gP", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
      end,
    },
  },
}
