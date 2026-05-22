local exec_async = require("config.utils").exec_async
local snacks = require("snacks")
local M = {}

local notify_opts = {
  title = "Git",
}

local function picker_width(fraction, min_cols)
  local ui = vim.api.nvim_list_uis()[1] or { width = 120 }
  return math.max(min_cols or 60, math.floor(ui.width * fraction))
end

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

local PR_FILTERS = {
  { name = "My PRs", search = "author:@me" },
  { name = "Review requested", search = "user-review-requested:@me" },
  { name = "All open", search = "" },
}

local pr_filter_idx = 1

local function open_gh_pr()
  local f = PR_FILTERS[pr_filter_idx]
  snacks.picker.gh_pr({
    search = f.search,
    title = "  PRs · " .. f.name,
    win = {
      input = {
        keys = {
          ["<C-o>"] = {
            function(picker)
              pr_filter_idx = pr_filter_idx % #PR_FILTERS + 1
              picker:close()
              vim.schedule(open_gh_pr)
            end,
            mode = { "n", "i" },
            desc = "Cycle PR filter",
          },
        },
      },
    },
  })
end

function M.gh_pr_picker()
  open_gh_pr()
end

function M.gh_switch_account()
  vim.notify("Loading github accounts...", vim.log.levels.INFO, notify_opts)

  get_gh_accounts(function(accounts)
    if not accounts then
      return
    end

    -- Get current login to exclude from the list
    vim.system({ "gh", "api", "user", "-q", ".login" }, {}, function(result)
      vim.schedule(function()
        local current_login = result.code == 0 and result.stdout:gsub("%s+", "") or ""

        local filtered = vim.tbl_filter(function(account)
          return account ~= current_login
        end, accounts)

        if #filtered == 0 then
          vim.notify("No other GitHub accounts to switch to", vim.log.levels.INFO, notify_opts)
          return
        end

        local items = {}

        for _, account in ipairs(filtered) do
          table.insert(items, { text = account })
        end

        snacks.picker.pick({
          finder = function()
            return items
          end,
          format = "text",
          layout = {
            layout = {
              title = "GH Account (" .. current_login .. ")",
              box = "vertical",
              position = "float",
              width = picker_width(0.2, 60),
              height = 0.15,
              border = "rounded",
              { win = "input", height = 1, border = "bottom" },
              { win = "list" },
            },
          },
          confirm = function(picker, item)
            picker:close()

            if not item then
              return
            end

            exec_async({ "gh", "auth", "switch", "-u", item.text }, {
              notify = notify_opts,
              info_label = "Switching to " .. item.text .. "...",
              success_label = "Switched to " .. item.text,
              failed_label = "Failed to switch account: ",
            })
          end,
        })
      end)
    end)
  end)
end

function M.create_pr()
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

    vim.system({ "gh", "api", "user", "-q", ".login" }, {}, function(login_result)
      vim.schedule(function()
        local current_login = login_result.code == 0 and login_result.stdout:gsub("%s+", "") or ""
        local prompt = current_login ~= "" and ("Select base branch (" .. current_login .. "): ")
          or "Select base branch: "

        get_branches(true, true)(function(branches)
          if not branches then
            return
          end

          vim.ui.select(branches, { prompt = prompt }, function(selected)
            if selected then
              callback(selected)
            end
          end)
        end)
      end)
    end)
  end

  -- Helper function: Prompt for title
  local function prompt_title(callback)
    local default_title = vim.fn.system("git log -1 --pretty=%s"):gsub("\n$", "")

    snacks.input({ prompt = "PR Title: ", default = default_title }, function(title)
      if title and title ~= "" then
        callback(title)
      end
    end)
  end

  -- Helper function: Prompt for body (multi-line floating textbox)
  local function prompt_body(callback)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "markdown"

    local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
    local width = math.floor(ui.width * 0.8)
    local height = math.floor(ui.height * 0.7)

    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((ui.height - height) / 2),
      col = math.floor((ui.width - width) / 2),
      style = "minimal",
      border = "rounded",
      title = " PR Body — <C-CR> confirm, Q cancel ",
      title_pos = "center",
    })

    local done = false

    local function finish(submit)
      if done then
        return
      end
      done = true

      local body = ""

      if submit then
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        body = table.concat(lines, "\n")
      end

      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end

      callback(body)
    end

    local map_opts = { buffer = buf, nowait = true, silent = true }

    vim.keymap.set({ "n", "i" }, "<C-CR>", function()
      finish(true)
    end, map_opts)

    vim.keymap.set("n", "q", function()
      finish(false)
    end, map_opts)
  end

  -- Helper function: Select reviewers (multi-select via Snacks picker)
  local function select_reviewers(callback)
    vim.notify("Loading reviewers...", vim.log.levels.INFO, notify_opts)

    local function show_picker(items)
      snacks.picker.pick({
        finder = function()
          return items
        end,
        format = "text",
        layout = {
          layout = {
            title = "Select reviewers",
            box = "vertical",
            position = "float",
            width = picker_width(0.2, 60),
            height = 0.3,
            border = "rounded",
            { win = "input", height = 1, border = "bottom" },
            { win = "list" },
          },
        },
        multi = { "confirm" },
        actions = {
          select_and_clear = function(picker)
            picker.list:select()
            vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, { "" })
          end,
        },
        win = {
          input = {
            keys = {
              ["<Tab>"] = { "select_and_clear", mode = { "i", "n" } },
            },
          },
        },
        confirm = function(picker)
          local selected = picker:selected()
          local reviewers = {}

          for _, sel in ipairs(selected) do
            table.insert(reviewers, sel.text)
          end

          picker:close()
          vim.schedule(function()
            callback(table.concat(reviewers, ","))
          end)
        end,
      })
    end

    vim.system({ "gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner" }, {}, function(repo_result)
      vim.schedule(function()
        if repo_result.code ~= 0 then
          show_picker({})
          return
        end

        local repo = repo_result.stdout:gsub("\n", "")

        vim.system(
          { "gh", "api", "repos/" .. repo .. "/collaborators", "--jq", ".[].login" },
          {},
          function(collab_result)
            vim.schedule(function()
              local items = {}

              if collab_result.code == 0 then
                for line in collab_result.stdout:gmatch("[^\r\n]+") do
                  table.insert(items, { text = line })
                end
              end

              show_picker(items)
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
    local head_branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
    local args = { "gh", "pr", "create", "--base", data.base, "--head", head_branch, "--title", data.title }

    table.insert(args, "--body")
    table.insert(args, '"' .. data.body .. '"')

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

    local cmd_str = table.concat(args, " ")

    vim.notify("PR Creating...", vim.log.levels.INFO, notify_opts)

    exec_async({ "git", "push", "-u", "origin", "HEAD" }, {
      notify = notify_opts,
      supress_notify = true,
      failed_label = "Failed to push branch: ",
      on_success = function()
        exec_async(args, {
          notify = notify_opts,
          success_label = "PR created successfully: ",
          failed_label = "Failed to create PR: ",
          on_success = function()
            vim.cmd("stopinsert")
          end,
          on_failure = function()
            vim.notify("Command:\n" .. cmd_str, vim.log.levels.WARN, notify_opts)
          end,
        })
      end,
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
  local function checkout(branch)
    exec_async({ "git", "checkout", branch }, {
      notify = notify_opts,
      success_label = "Checked out " .. branch,
      failed_label = "Failed to checkout branch: ",
    })
  end

  get_branches(false, true)(function(branches)
    if not branches then
      return
    end

    local items = {}

    for _, branch in ipairs(branches) do
      table.insert(items, { text = branch })
    end

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = "text",
      layout = {
        layout = {
          title = "Select branch",
          box = "vertical",
          position = "float",
          width = picker_width(0.7, 80),
          height = 0.4,
          border = "rounded",
          { win = "input", height = 1, border = "bottom" },
          { win = "list" },
        },
      },
      confirm = function(picker, item)
        picker:close()
        if item then
          checkout(item.text)
        end
      end,
    })
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

  snacks.input({
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

function M.git_restore_all()
  vim.fn.system({ "git", "clean", "-f" })
  vim.fn.system({ "git", "checkout", "." })
  vim.notify("Git cleaned", vim.log.levels.INFO, { title = "Git" })
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
            M.git_push(amend)
          end,
        })
      end)
    end
  end

  snacks.input({
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
