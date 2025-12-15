local M = {}

local notify_opts = {
  title = "Git",
}

function M.get_current_file_history()
  local current_file = vim.fn.expand("%:.")
  vim.cmd("DiffviewFileHistory " .. current_file)
end

function M.git_pull()
  vim.notify("Pulling...", vim.log.levels.INFO, notify_opts)

  vim.system({ "git", "pull" }, {}, function(pull_result)
    vim.schedule(function()
      if pull_result.code == 0 then
        vim.notify("Pull successful", vim.log.levels.INFO, notify_opts)
      else
        vim.notify("Pull failed: " .. (pull_result.stderr or "unknown error"), vim.log.levels.ERROR, notify_opts)
      end
    end)
  end)
end

function M.close_diffview()
  vim.g.diffview_active = false
  vim.cmd("DiffviewClose")
end

function M.git_commit(amend)
  local branch = vim.b.gitsigns_head or vim.fn.system("git branch --show-current"):gsub("\n", "")

  -- Get current commit message when amending
  local default_msg = ""

  if amend then
    -- Use %s to get only the subject line (first line) to avoid newline issues
    default_msg = vim.fn.system("git log -1 --pretty=%s"):gsub("\n$", "")
  end

  local function on_push_done(push_result)
    vim.schedule(function()
      if push_result.code == 0 then
        vim.notify("Pushed to: " .. branch, vim.log.levels.INFO, notify_opts)
      else
        vim.notify("Failed to push: " .. (push_result.stderr or "unknown error"), vim.log.levels.ERROR, notify_opts)
      end
    end)
  end

  local function on_commit_done(commit_result)
    vim.schedule(function()
      if commit_result.code ~= 0 then
        vim.notify("Commit failed: " .. (commit_result.stderr or "unknown error"), vim.log.levels.ERROR, notify_opts)
        return
      end
      vim.notify("Committed, pushing to: " .. branch .. "...", vim.log.levels.INFO, notify_opts)

      -- Build push args with --force when amending
      local push_args = { "git", "push" }

      if amend then
        table.insert(push_args, "--force")
      end

      vim.system(push_args, {}, on_push_done)
    end)
  end

  local function on_input(msg)
    if msg and msg ~= "" then
      vim.schedule(function()
        M.close_diffview()

        -- Build commit args with --amend when needed
        local commit_args = { "git", "commit" }
        if amend then
          table.insert(commit_args, "--amend")
        end
        table.insert(commit_args, "-m")
        table.insert(commit_args, msg)

        vim.system(commit_args, {}, on_commit_done)
      end)
    end
  end

  require("snacks").input({
    prompt = amend and "Amend commit: " or "Commit to: " .. branch .. " :",
    default = default_msg,
  }, on_input)
end

function M.git_commit_amend()
  M.git_commit(true)
end

function M.git_diff_branch()
  local function on_branch_selected(selected)
    if selected then
      vim.cmd("DiffviewOpen " .. selected)
    end
  end

  local function on_branches_fetched(branch_result)
    vim.schedule(function()
      if branch_result.code ~= 0 then
        vim.notify("Failed to get branches", vim.log.levels.ERROR, notify_opts)
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

return M
