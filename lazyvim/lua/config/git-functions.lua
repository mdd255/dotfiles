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

  get_branches(false, true)(function(branches)
    if not branches then
      return
    end
    vim.ui.select(branches, { prompt = "Select branch to diff: " }, on_branch_selected)
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
    vim.notify("Creating PR " .. data.title .. "...", vim.log.levels.INFO, notify_opts)
    local args = { "gh", "pr", "create", "--base", data.base, "--title", data.title }

    -- Always provide --body (required by gh CLI, even if empty)
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

    vim.system(args, {}, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify("PR created successfully: " .. data.title, vim.log.levels.INFO, notify_opts)
        else
          vim.notify("Failed to create PR: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR, notify_opts)
        end
      end)
    end)
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

return M
