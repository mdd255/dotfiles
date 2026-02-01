local exec_async = require("config.utils").exec_async
local M = {}

local notify_opts = {
  title = "Git",
}

-- Helper function to get list of branches
-- @param exclude_current: boolean - whether to exclude current branch
-- @param unique: boolean - whether to ensure unique values
-- @return function that takes a callback
local function get_branches(exclude_current, unique)
  return function(callback)
    vim.system({ "git", "branch", "-a" }, {}, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify("Failed to get branches", vim.log.levels.ERROR, notify_opts)
          callback(nil)
          return
        end

        local current_branch = nil

        if exclude_current then
          current_branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
        end

        local branches = {}
        local seen = {}

        for line in result.stdout:gmatch("[^\r\n]+") do
          local branch = line:gsub("^%s*%*?%s*", ""):gsub("^remotes/origin/", "")

          local should_include = branch ~= ""
            and not branch:match("HEAD")
            and (not exclude_current or branch ~= current_branch)
            and (not unique or not seen[branch])

          if should_include then
            table.insert(branches, branch)

            if unique then
              seen[branch] = true
            end
          end
        end

        callback(branches)
      end)
    end)
  end
end

-- Helper function to get list of recent commits
-- @param limit: number - how many recent commits to fetch
-- @return function that takes a callback
local function get_recent_commits(limit)
  return function(callback)
    vim.system({ "git", "log", "--oneline", "--max-count=" .. (limit or 30) }, {}, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify("Failed to get commits", vim.log.levels.ERROR, notify_opts)
          callback(nil)
          return
        end

        local commits = {}

        for line in result.stdout:gmatch("[^\r\n]+") do
          if line ~= "" then
            table.insert(commits, line)
          end
        end

        callback(commits)
      end)
    end)
  end
end

local function get_gh_accounts(callback)
  vim.system({ "gh", "auth", "status" }, {}, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(
          "Failed to get GitHub accounts: " .. (result.stderr or "unknown error"),
          vim.log.levels.ERROR,
          notify_opts
        )

        callback(nil)
        return
      end

      local seen = {}
      local accounts = {}

      for line in (result.stdout or ""):gmatch("[^\r\n]+") do
        local account = line:match(" account (%S+) %(")

        if account and not seen[account] then
          seen[account] = true
          table.insert(accounts, account)
        end
      end

      if #accounts == 0 then
        vim.notify("No GitHub accounts found", vim.log.levels.WARN, notify_opts)
        callback(nil)
        return
      end

      callback(accounts)
    end)
  end)
end

function M.gh_switch_account()
  vim.notify("Loading github accounts...", vim.log.levels.INFO, notify_opts)

  get_gh_accounts(function(accounts)
    if not accounts then
      return
    end

    vim.ui.select(accounts, {
      prompt = "Switch GitHub account:",
    }, function(selected)
      if not selected then
        return
      end

      exec_async({ "gh", "auth", "switch", "-u", selected }, {
        notify = notify_opts,
        info_label = "Switching to " .. selected .. "...",
        success_label = "Switched to " .. selected,
        failed_label = "Failed to switch account: ",
      })
    end)
  end)
end

function M.create_pr()
  vim.notify("Creating PR...", vim.log.levels.INFO, notify_opts)

  local pr_data = {
    assignee = "@me",
    base = nil,
    title = nil,
    body = nil,
    reviewers = "",
    label = "",
  }

  -- Helper function: Select base branch
  local function select_base_branch(callback)
    vim.notify("Loading base branches...", vim.log.levels.INFO, notify_opts)

    get_branches(true, true)(function(branches)
      if not branches then
        return
      end

      vim.ui.select(branches, { prompt = "Select base branch: " }, function(selected)
        if selected then
          callback(selected)
        end
      end)
    end)
  end

  -- Helper function: Prompt for title
  local function prompt_title(callback)
    local default_title = vim.fn.system("git log -1 --pretty=%s"):gsub("\n$", "")

    require("snacks").input({ prompt = "PR Title: ", default = default_title }, function(title)
      if title and title ~= "" then
        callback(title)
      end
    end)
  end

  -- Helper function: Prompt for body
  local function prompt_body(callback)
    require("snacks").input({ prompt = "PR Body (optional): ", default = "" }, function(body)
      callback(body or "")
    end)
  end

  -- Helper function: Select reviewers
  local function select_reviewers(callback)
    vim.notify("Loading reviewers...", vim.log.levels.INFO, notify_opts)

    vim.system({ "gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner" }, {}, function(repo_result)
      vim.schedule(function()
        if repo_result.code ~= 0 then
          callback("")
          return
        end

        local repo = repo_result.stdout:gsub("\n", "")

        vim.system(
          { "gh", "api", "repos/" .. repo .. "/collaborators", "--jq", ".[].login" },
          {},
          function(collab_result)
            vim.schedule(function()
              if collab_result.code ~= 0 then
                callback("")
                return
              end

              local collaborators = {}
              for line in collab_result.stdout:gmatch("[^\r\n]+") do
                table.insert(collaborators, line)
              end

              local selected_reviewers = {}

              local function select_next()
                local available = {}

                for _, collab in ipairs(collaborators) do
                  local already_selected = false

                  for _, selected in ipairs(selected_reviewers) do
                    if selected == collab then
                      already_selected = true
                      break
                    end
                  end

                  if not already_selected then
                    table.insert(available, collab)
                  end
                end

                if #available == 0 then
                  callback(table.concat(selected_reviewers, ","))
                  return
                end

                table.insert(available, 1, "Done (no more reviewers)")

                vim.ui.select(available, {
                  prompt = #selected_reviewers > 0
                      and "Select another reviewer (selected: " .. #selected_reviewers .. "):"
                    or "Select reviewer (optional):",
                }, function(selected)
                  if not selected or selected == "Done (no more reviewers)" then
                    callback(table.concat(selected_reviewers, ","))
                  else
                    table.insert(selected_reviewers, selected)
                    select_next()
                  end
                end)
              end

              select_next()
            end)
          end
        )
      end)
    end)
  end

  -- Helper function: Prompt for label
  local function prompt_label(callback)
    require("snacks").input({ prompt = "Label (optional): ", default = "" }, function(label)
      callback(label or "")
    end)
  end

  -- Helper function: Create PR with gh
  local function create_pr_with_gh(data)
    local args = { "gh", "pr", "create", "--base", data.base, "--title", data.title }

    table.insert(args, "--body")
    table.insert(args, data.body)

    if data.assignee ~= "" then
      table.insert(args, "--assignee")
      table.insert(args, data.assignee)
    end

    if data.reviewers ~= "" then
      table.insert(args, "--reviewer")
      table.insert(args, data.reviewers)
    end

    if data.label ~= "" then
      table.insert(args, "--label")
      table.insert(args, data.label)
    end

    exec_async(args, {
      notify = notify_opts,
      info_label = "Creating PR " .. data.title .. "...",
      success_label = "PR created successfully: " .. data.title,
      failed_label = "Failed to create PR: ",
    })
  end

  -- Start the workflow
  select_base_branch(function(base)
    pr_data.base = base
    prompt_title(function(title)
      pr_data.title = title
      prompt_body(function(body)
        pr_data.body = body
        select_reviewers(function(reviewers)
          pr_data.reviewers = reviewers
          prompt_label(function(label)
            pr_data.label = label
            create_pr_with_gh(pr_data)
          end)
        end)
      end)
    end)
  end)
end

-- Exported functions

function M.git_add_all()
  exec_async({ "git", "add", "." }, {
    notify = notify_opts,
    success_label = "All changes staged successfully",
    failed_label = "Failed to stage changes: ",
  })
end

function M.git_checkout_branch()
  local function on_branch_selected(selected)
    if selected then
      exec_async({ "git", "checkout", selected }, {
        notify = notify_opts,
        success_label = "Checked out " .. selected,
        failed_label = "Failed to checkout branch: ",
      })
    end
  end

  get_branches(false, true)(function(branches)
    if not branches then
      return
    end
    vim.ui.select(branches, { prompt = "Select branch to checkout: " }, on_branch_selected)
  end)
end

function M.git_checkout_new_branch()
  local function on_input(branch_name)
    if branch_name and branch_name ~= "" then
      exec_async({ "git", "checkout", "-b", branch_name }, {
        notify = notify_opts,
        success_label = "Created and checked out " .. branch_name,
        failed_label = "Failed to create branch: ",
      })
    end
  end

  require("snacks").input({
    prompt = "New branch name: ",
  }, on_input)
end

function M.git_delete_branch()
  local function on_branch_selected(selected)
    if selected then
      exec_async({ "git", "branch", "-d", selected }, {
        notify = notify_opts,
        success_label = "Deleted " .. selected,
        failed_label = "Failed to delete branch (use -D to force): ",
      })
    end
  end

  get_branches(true, true)(function(branches)
    if not branches then
      return
    end
    vim.ui.select(branches, { prompt = "Select branch to delete: " }, on_branch_selected)
  end)
end

function M.git_cherry_pick()
  local function on_commit_selected(selected)
    if selected then
      -- Extract commit hash (first word before space)
      local hash = selected:match("^(%S+)")
      exec_async({ "git", "cherry-pick", hash }, {
        notify = notify_opts,
        info_label = "Cherry-picking " .. hash .. "...",
        success_label = "Cherry-picked " .. hash,
        failed_label = "Failed to cherry-pick: ",
      })
    end
  end

  get_recent_commits(30)(function(commits)
    if not commits then
      return
    end
    vim.ui.select(commits, { prompt = "Select commit to cherry-pick: " }, on_commit_selected)
  end)
end

function M.git_cherry_pick_abort()
  exec_async({ "git", "cherry-pick", "--abort" }, {
    notify = notify_opts,
    success_label = "Cherry-pick aborted",
    failed_label = "Failed to abort cherry-pick: ",
  })
end

function M.git_revert()
  local function on_commit_selected(selected)
    if selected then
      -- Extract commit hash (first word before space)
      local hash = selected:match("^(%S+)")
      exec_async({ "git", "revert", hash, "--no-edit" }, {
        notify = notify_opts,
        success_label = "Reverted " .. hash,
        failed_label = "Failed to revert: ",
      })
    end
  end

  get_recent_commits(30)(function(commits)
    if not commits then
      return
    end
    vim.ui.select(commits, { prompt = "Select commit to revert: " }, on_commit_selected)
  end)
end

function M.get_current_file_history()
  local current_file = vim.fn.expand("%:.")
  vim.cmd("DiffviewFileHistory " .. current_file)
end

function M.git_stash_push()
  exec_async({ "git", "stash", "push", "-u" }, {
    notify = notify_opts,
    success_label = "Stash pushed successful",
    failed_label = "Stash push failed",
  })
end

function M.git_status()
  exec_async({ "git", "status", "--short" }, {
    notify = notify_opts,
    success_label = "Git status:",
    failed_label = "Failed to get status: ",
  })
end

function M.git_stash_drop()
  exec_async({ "git", "stash", "drop" }, {
    notify = notify_opts,
    success_label = "Stash dropped successful",
    failed_label = "Stash drop failed",
  })
end

function M.git_reset_hard()
  exec_async({ "git", "reset", "--hard", "HEAD" }, {
    notify = notify_opts,
    success_label = "Hard reset to HEAD successful",
    failed_label = "Hard reset to HEAD failed",
  })
end

function M.git_reset_soft()
  exec_async({ "git", "reset", "--soft", "HEAD" }, {
    notify = notify_opts,
    success_label = "Soft reset to HEAD successful",
    failed_label = "Soft reset to HEAD failed",
  })
end

function M.git_restore_staged()
  exec_async({ "git", "restore", "--staged", "." }, {
    notify = notify_opts,
    success_label = "Restored successful",
    failed_label = "Restore failed",
  })
end

function M.git_pull()
  exec_async({ "git", "pull" }, {
    notify = notify_opts,
    info_label = "Pulling...",
    success_label = "Pull successful",
    failed_label = "Pull failed: ",
  })
end

function M.close_diffview()
  vim.g.diffview_active = false
  vim.cmd("DiffviewClose")
end

function M.git_push(force)
  local branch = vim.b.gitsigns_head or vim.fn.system("git branch --show-current"):gsub("\n", "")

  local push_args = { "git", "push" }

  if force then
    table.insert(push_args, "--force")
  end

  exec_async(push_args, {
    notify = notify_opts,
    info_label = "Pushing to: " .. branch .. "...",
    success_label = "Pushed to: " .. branch,
    failed_label = "Failed to push: ",
  })
end

function M.git_commit(amend)
  local branch = vim.b.gitsigns_head or vim.fn.system("git branch --show-current"):gsub("\n", "")

  -- Get current commit message when amending
  local default_msg = ""

  if amend then
    -- Use %s to get only the subject line (first line) to avoid newline issues
    default_msg = vim.fn.system("git log -1 --pretty=%s"):gsub("\n$", "")
  end

  local function on_input(msg)
    if msg and msg ~= "" then
      vim.schedule(function()
        M.close_diffview()

        local commit_args = { "git", "commit" }
        if amend then
          table.insert(commit_args, "--amend")
        end
        table.insert(commit_args, "-m")
        table.insert(commit_args, msg)

        exec_async(commit_args, {
          notify = notify_opts,
          info_label = "Committing...",
          success_label = "Committed successfully",
          failed_label = "Commit failed: ",
          on_success = function()
            M.git_push(false)
          end,
        })
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

  get_branches(false, true)(function(branches)
    if not branches then
      return
    end

    vim.ui.select(branches, { prompt = "Select branch to diff: " }, on_branch_selected)
  end)
end

return M
