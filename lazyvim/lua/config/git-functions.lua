local utils = require("config.utils")
local exec_async = utils.exec_async
local custom_layout = utils.custom_layout
local custom_input = utils.custom_input
local make_refresh_action = utils.make_refresh_action
local HL = utils.HL
local float_input = utils.float_input
local cache = require("config.cache")
local snacks = require("snacks")
local M = {}

-- Runs a chain of async steps sequentially without nesting.
-- Each step: function(data, continue) — call continue(data) to advance.
local function step_chain(steps, initial_data)
  local function go(i, data)
    if i > #steps then
      return
    end
    steps[i](data, function(d)
      go(i + 1, d)
    end)
  end
  go(1, initial_data)
end

local function format_branch(item, current_branch)
  if current_branch and item.text == current_branch then
    return { { item.text, "DiagnosticOk" } }
  end

  local is_main = item.text == "main" or item.text == "master"
  return { { item.text, is_main and "DiagnosticWarn" or "Function" } }
end

local notify_opts = {
  title = " Git",
}

local GH_TTL_MS = 5 * 60 * 60 * 1000 -- 5 h

-- Prompt for SSH key passphrase, write a temp SSH_ASKPASS helper script,
-- then call fn(env, cleanup). env is nil when passphrase is empty (key unlocked).
local function with_ssh_passphrase(fn)
  float_input("  SSH passphrase ", { secret = true, border_hl = "FloatBorder" }, function(passphrase)
    if passphrase == "" then
      fn(nil, function() end)
      return
    end

    local tmp = vim.fn.tempname() .. ".sh"
    local uv = vim.uv or vim.loop
    -- Create owner-only (0700) from birth via fs_open: the file holds the SSH
    -- passphrase in plaintext, so it must never be group/world-readable. io.open
    -- would create it 0644 and a later `chmod +x` leaves a brief readable window.
    local fd = uv.fs_open(tmp, "w", tonumber("700", 8))

    if not fd then
      vim.notify("Failed to create SSH askpass script", vim.log.levels.ERROR, notify_opts)
      -- Fall back to the no-askpass path instead of stranding the caller: fn must
      -- still fire or the push/pull/checkout that awaits it hangs forever.
      fn(nil, function() end)
      return
    end

    -- Use printf to safely echo passphrase; escape single quotes in passphrase.
    local safe = passphrase:gsub("'", "'\\''")
    uv.fs_write(fd, "#!/bin/sh\nprintf '%s\\n' '" .. safe .. "'\n")
    uv.fs_close(fd)

    local env = { SSH_ASKPASS = tmp, SSH_ASKPASS_REQUIRE = "force", DISPLAY = ":0" }

    local cleanup = function()
      os.remove(tmp)
    end

    fn(env, cleanup)
  end)
end

-- Shared async shell helper: runs cmd, calls parse_fn(stdout) on success.
-- Returns function(callback) matching the pattern used by get_* helpers.
local function system_async(cmd, err_msg, parse_fn)
  return function(callback)
    vim.system(cmd, {}, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify(err_msg, vim.log.levels.ERROR, notify_opts)
          callback(nil)
          return
        end
        callback(parse_fn(result.stdout))
      end)
    end)
  end
end

-- Helper function to get list of branches (no cache — cheap local command).
-- @param exclude_current: boolean - whether to exclude current branch
-- @param unique: boolean - whether to ensure unique values
-- @return function that takes a callback
local function get_branches(exclude_current, unique)
  return function(callback)
    vim.system({ "git", "branch", "-a", "--sort=-committerdate" }, {}, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify("Failed to get branches", vim.log.levels.ERROR, notify_opts)
          callback(nil)
          return
        end

        -- Single pass: `git branch -a` lists the local `* current` entry before
        -- its `remotes/origin/<current>` duplicate, so the current branch is
        -- always discovered before exclude_current needs to compare against it.
        local branches = {}
        local seen = {}
        local current_branch = nil
        local worktree_set = {}

        for line in result.stdout:gmatch("[^\r\n]+") do
          if line:match("^%*") then
            current_branch = line:gsub("^%s*%*%s*", ""):gsub("^remotes/origin/", "")
          end

          if line:match("^%+") then
            local wt = line:gsub("^%s*%+%s*", ""):gsub("^remotes/origin/", "")
            worktree_set[wt] = true
          end

          local branch = line:gsub("^%s*[%*%+]?%s*", ""):gsub("^remotes/origin/", "")

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

        callback(branches, worktree_set)
      end)
    end)
  end
end

-- Shared branch picker. Fetches branches, renders them with the standard branch
-- formatting (current = green, main/master = warn, worktree tag), then calls
-- on_confirm(branch) with the selected branch name.
-- @param opts table:
--   title           string   - picker title text
--   title_hl        string   - title highlight group (default "DiagnosticInfo")
--   exclude_current boolean  - drop the current branch from the list
--   on_confirm      function - called with the selected branch name
--   format          function - optional (item, current_branch) chunk override;
--                              replaces the default branch + worktree formatting
local function branch_picker(opts)
  local current_branch = vim.b.gitsigns_head or vim.fn.system("git branch --show-current"):gsub("\n", "")

  get_branches(opts.exclude_current, true)(function(branches, worktree_set)
    if not branches then
      return
    end

    local items = {}

    for _, branch in ipairs(branches) do
      table.insert(items, { text = branch, _in_worktree = worktree_set and worktree_set[branch] })
    end

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        if opts.format then
          return opts.format(item, current_branch)
        end

        local chunks = format_branch(item, current_branch)

        if item._in_worktree then
          table.insert(chunks, { "  worktree", "Comment" })
        end

        return chunks
      end,
      layout = custom_layout({
        title = { { opts.title, opts.title_hl or "DiagnosticInfo" } },
        width = 0.55,
      }),
      confirm = function(picker, item)
        picker:close()

        if item then
          opts.on_confirm(item.text)
        end
      end,
    })
  end)
end

local function get_recent_commits(limit)
  return system_async(
    { "git", "log", "--oneline", "--max-count=" .. (limit or 30) },
    "Failed to get commits",
    function(out)
      local commits = {}
      for line in out:gmatch("[^\r\n]+") do
        if line ~= "" then
          table.insert(commits, line)
        end
      end
      return commits
    end
  )
end

local function get_stashes()
  return system_async({ "git", "stash", "list" }, "Failed to get stashes", function(out)
    local items = {}
    for line in out:gmatch("[^\r\n]+") do
      if line ~= "" then
        table.insert(items, { text = line, ref = line:match("^(stash@{%d+})") })
      end
    end
    if #items == 0 then
      vim.notify("No stashes found", vim.log.levels.INFO, notify_opts)
      return nil
    end
    return items
  end)
end

-- Shared stash picker layout factory.
-- @param title string - picker title
-- @param on_confirm function - called with selected item
local function stash_picker(title, on_confirm, title_hl)
  get_stashes()(function(items)
    if not items then
      return
    end

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        local ref = item.text:match("^(stash@{%d+})")
        if ref then
          local rest = item.text:sub(#ref + 3)
          return {
            { ref, "DiagnosticInfo" },
            { ": " .. rest, "Comment" },
          }
        end
        return { { item.text, "Comment" } }
      end,
      layout = custom_layout({
        title = { { " " .. title, title_hl or "DiagnosticInfo" } },
        width = 0.55,
      }),
      confirm = function(picker, item)
        picker:close()

        if item then
          on_confirm(item)
        end
      end,
    })
  end)
end

-- Cached GH accounts fetcher (5 h TTL — network call, warmed on session load).
local get_gh_accounts = cache.wrap("gh.accounts", GH_TTL_MS, function(callback)
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
end)

-- Cached current GH login fetcher (5 h TTL — warmed on session load).
local fetch_current_login = cache.wrap("gh.current_login", GH_TTL_MS, function(callback)
  vim.system({ "gh", "api", "user", "-q", ".login" }, {}, function(result)
    vim.schedule(function()
      local login = result.code == 0 and result.stdout:gsub("%s+", "") or ""
      callback(login)
    end)
  end)
end)

-- Cached repo name fetcher (5 h TTL — never changes within a session).
local fetch_repo_name = cache.wrap("gh.repo_name", GH_TTL_MS, function(callback)
  vim.system({ "gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner" }, {}, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        callback(nil)
        return
      end

      callback(result.stdout:gsub("\n", ""))
    end)
  end)
end)

-- Cached collaborators fetcher (5 h TTL — warmed on session load).
local fetch_collaborators = cache.wrap("gh.collaborators", GH_TTL_MS, function(callback)
  fetch_repo_name(function(repo)
    if not repo then
      callback({})
      return
    end

    vim.system({ "gh", "api", "repos/" .. repo .. "/collaborators", "--jq", ".[].login" }, {}, function(collab_result)
      vim.schedule(function()
        local items = {}

        if collab_result.code == 0 then
          for line in collab_result.stdout:gmatch("[^\r\n]+") do
            table.insert(items, { text = line })
          end
        end

        callback(items)
      end)
    end)
  end)
end)

-- ── Shared PR helpers (module-level so PR picker + create_pr both use them) ───

-- Multi-line floating text editor. default_lines: optional table of strings.
local function prompt_body(default_lines, callback)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"

  if default_lines and #default_lines > 0 then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, default_lines)
  end

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
    title = "  PR Body — <C-CR> confirm ",
    title_pos = "center",
  })

  vim.cmd("startinsert")

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

-- Multi-select reviewer picker. title: optional string override.
local function select_reviewers(title, callback)
  if not cache.is_cached("gh.collaborators") then
    vim.notify("Loading reviewers...", vim.log.levels.INFO, notify_opts)
  end

  local function show_picker(items)
    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        return { { item.text, "Function" } }
      end,
      layout = custom_layout({
        title = { { title or "  Select reviewers ", "Function" } },
        width = 0.3,
      }),
      multi = { "confirm" },
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

  fetch_collaborators(show_picker)
end

-- ── PR picker ─────────────────────────────────────────────────────────────────

local PR_FILTERS = {
  { name = "All open", search = "" },
  { name = "My PRs", search = "author:@me" },
  { name = "Review requested", search = "user-review-requested:@me" },
}

local pr_filter_idx = 1

local PR_TTL_MS = 5 * 60 * 1000 -- 5m

local MERGE_STATE_ICONS = {
  CLEAN = "",
  DIRTY = "󰄰",
  BEHIND = "󰄰",
  BLOCKED = "",
  UNSTABLE = "󰄰",
  DRAFT = "󰄰",
  UNKNOWN = "󰄰",
}

local REVIEW_DECISION_ICONS = {
  APPROVED = " ",
  CHANGES_REQUESTED = " ",
  REVIEW_REQUIRED = " ",
}

local function make_pr_fetcher(filter)
  return function(callback)
    local cmd = {
      "gh",
      "pr",
      "list",
      "--limit",
      "50",
      "--json",
      "number,title,author,headRefName,baseRefName,isDraft,createdAt,updatedAt,reviewDecision,labels,url,body,additions,deletions,changedFiles,mergeable,mergeStateStatus",
    }

    if filter.search and filter.search ~= "" then
      vim.list_extend(cmd, { "--search", filter.search })
    end

    vim.system(cmd, {}, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify("Failed to list PRs: " .. (result.stderr or ""), vim.log.levels.ERROR, notify_opts)
          callback(nil)
          return
        end

        local ok, data = pcall(vim.json.decode, result.stdout or "[]")

        if not ok or type(data) ~= "table" then
          vim.notify("Failed to parse PR list", vim.log.levels.ERROR, notify_opts)
          callback(nil)
          return
        end

        callback(data)
      end)
    end)
  end
end

local function pr_cache_key(f)
  return "gh.prs." .. (f.search ~= "" and f.search or "all")
end

local gh_pr_fetchers = cache.wrap_filters(PR_FILTERS, PR_TTL_MS, pr_cache_key, make_pr_fetcher)

local function get_gh_prs(filter, callback)
  local key = pr_cache_key(filter)

  if not cache.is_cached(key) then
    vim.notify("Loading PRs...", vim.log.levels.INFO, notify_opts)
  end

  gh_pr_fetchers[key](callback)
end

-- Highlight maps keyed by mergeStateStatus / reviewDecision — module-level so
-- the picker format fn doesn't rebuild them for every rendered row.
local PR_STATE_HLS = {
  CLEAN = "DiagnosticOk",
  DIRTY = "DiagnosticError",
  BLOCKED = "DiagnosticError",
  BEHIND = "DiagnosticWarn",
  UNSTABLE = "DiagnosticWarn",
}

local PR_REVIEW_HLS = {
  APPROVED = "DiagnosticOk",
  CHANGES_REQUESTED = "DiagnosticError",
  REVIEW_REQUIRED = "DiagnosticWarn",
}

-- Preview badge strings — module-level so format_pr_items doesn't rebuild these
-- literal tables for every PR row.
local PR_STATE_BADGES = {
  CLEAN = "> ✅ **CLEAN**",
  DIRTY = "> ❌ **DIRTY**",
  BLOCKED = "> ⛔ **BLOCKED**",
  BEHIND = "> ⬇  **BEHIND**",
  UNSTABLE = "> ⚠  **UNSTABLE**",
}

local PR_REVIEW_BADGES = {
  APPROVED = "✅ APPROVED",
  CHANGES_REQUESTED = "❌ CHANGES REQUESTED",
  REVIEW_REQUIRED = "⏳ REVIEW REQUIRED",
}

local function format_pr_items(prs)
  local items = {}

  for _, pr in ipairs(prs) do
    local draft_icon = pr.isDraft and " " or " "
    local review_icon = REVIEW_DECISION_ICONS[pr.reviewDecision or ""] or " "
    local merge_icon = MERGE_STATE_ICONS[pr.mergeStateStatus or ""] or "?"

    local labels_str = #pr.labels > 0
        and table.concat(
          vim.tbl_map(function(l)
            return l.name
          end, pr.labels),
          ", "
        )
      or "—"

    local state_str = PR_STATE_BADGES[pr.mergeStateStatus or ""]
      or ("> ❓ **" .. (pr.mergeStateStatus or "UNKNOWN") .. "**")
    local review_str = PR_REVIEW_BADGES[pr.reviewDecision or ""] or "💬 no review"
    local draft_str = pr.isDraft and "  ·  📝 **DRAFT**" or ""
    local status_line = state_str .. "  ·  " .. review_str .. draft_str

    local preview_text = string.format(
      "%s\n\n# #%d %s\n\n**Author:** %s  **Branch:** `%s` → `%s`\n**Merge:** %s (%s)  **Review:** %s\n**Labels:** %s\n**+%d -%d** (%d files)\n\n---\n\n%s",
      status_line,
      pr.number,
      pr.title,
      pr.author.login,
      pr.headRefName,
      pr.baseRefName,
      pr.mergeStateStatus or "UNKNOWN",
      pr.mergeable or "UNKNOWN",
      pr.reviewDecision or "none",
      labels_str,
      pr.additions,
      pr.deletions,
      pr.changedFiles,
      pr.body ~= "" and pr.body or "_No description_"
    )

    table.insert(items, {
      text = string.format(
        "%s %s %s #%-5d %-38s  %-20s  %s",
        draft_icon,
        review_icon,
        merge_icon,
        pr.number,
        pr.title:sub(1, 36),
        pr.headRefName:sub(1, 18),
        pr.author.login
      ),
      _pr = pr,
      preview = { text = preview_text, ft = "markdown" },
    })
  end

  return items
end

local pr_mutate_success = function()
  cache.invalidate_pattern("gh.prs")
end

local PR_ACTIONS = {
  { text = "󰿄 Checkout", key = "checkout", hl = "DiagnosticOk" },
  { text = "󰊯 Open browser", key = "browser", hl = "DiagnosticInfo" },
  { text = " Copy URL", key = "copy_url", hl = "DiagnosticInfo" },
  { text = " View diff", key = "diff", hl = "DiagnosticInfo" },
  { text = " Merge", key = "merge", hl = "DiagnosticWarn" },
  { text = " Merge squash", key = "squash", hl = "DiagnosticWarn" },
  { text = " Approve", key = "approve", hl = "DiagnosticOk" },
  { text = " Comment", key = "comment", hl = "Function" },
  { text = " Edit title", key = "edit_title", hl = "Function" },
  { text = " Edit body", key = "edit_body", hl = "Function" },
  { text = " Edit reviewers", key = "edit_reviewers", hl = "Function" },
  { text = " Close PR", key = "close", hl = "DiagnosticError" },
  { text = " Convert to draft", key = "to_draft", hl = "Comment" },
  { text = " Ready to review", key = "ready", hl = "DiagnosticOk" },
  { text = " View checks", key = "checks", hl = "DiagnosticInfo" },
  { text = " Request changes", key = "request_changes", hl = "DiagnosticError" },
  { text = " Add label", key = "add_label", hl = "Function" },
  { text = "󰑓 Reopen", key = "reopen", hl = "DiagnosticOk" },
}

local function handle_pr_action(action_key, pr)
  local id = tostring(pr.number)
  local pr_num = "#" .. id
  local label = pr_num .. " " .. pr.title

  if action_key == "checkout" then
    with_ssh_passphrase(function(env, cleanup)
      exec_async({ "gh", "pr", "checkout", id }, {
        notify = notify_opts,
        env = env,
        info_label = "Checking out " .. label .. "...",
        success_label = "Checked out: " .. label,
        failed_label = "Failed to checkout: ",
        on_success = cleanup,
        on_failure = cleanup,
      })
    end)
  elseif action_key == "browser" then
    exec_async({ "gh", "pr", "view", id, "--web" }, {
      notify = notify_opts,
      suppress_notify = true,
      failed_label = "Failed to open browser: ",
    })
  elseif action_key == "diff" then
    exec_async({ "gh", "pr", "checkout", id }, {
      notify = notify_opts,
      suppress_notify = true,
      failed_label = "Failed to checkout for diff: ",
      on_success = function()
        vim.schedule(function()
          vim.cmd("DiffviewOpen " .. pr.baseRefName .. "...HEAD")
        end)
      end,
    })
  elseif action_key == "merge" then
    exec_async({ "gh", "pr", "merge", id, "--merge" }, {
      notify = notify_opts,
      info_label = "Merging " .. label .. "...",
      success_label = "Merged: " .. label,
      failed_label = "Failed to merge: ",
      on_success = pr_mutate_success,
    })
  elseif action_key == "squash" then
    exec_async({ "gh", "pr", "merge", id, "--squash" }, {
      notify = notify_opts,
      info_label = "Squash merging " .. label .. "...",
      success_label = "Squash merged: " .. label,
      failed_label = "Failed to squash merge: ",
      on_success = pr_mutate_success,
    })
  elseif action_key == "approve" then
    exec_async({ "gh", "pr", "review", id, "--approve" }, {
      notify = notify_opts,
      success_label = "Approved: " .. label,
      failed_label = "Failed to approve: ",
      on_success = pr_mutate_success,
    })
  elseif action_key == "comment" then
    prompt_body({}, function(body)
      if body == "" then
        return
      end
      exec_async({ "gh", "pr", "comment", id, "--body", body }, {
        notify = notify_opts,
        success_label = "Comment added to: " .. label,
        failed_label = "Failed to add comment: ",
      })
    end)
  elseif action_key == "edit_title" then
    custom_input("  Edit title ", { default = pr.title }, function(title)
      if not title or title == "" then
        return
      end
      exec_async({ "gh", "pr", "edit", id, "--title", title }, {
        notify = notify_opts,
        success_label = "Title updated: " .. label,
        failed_label = "Failed to update title: ",
        on_success = pr_mutate_success,
      })
    end)
  elseif action_key == "edit_body" then
    -- vim.split with plain=true: `gmatch("[^\n]*")` matches the empty string
    -- between every newline, injecting phantom blank lines into the editor.
    local default_lines = vim.split(pr.body or "", "\n", { plain = true })
    prompt_body(default_lines, function(body)
      exec_async({ "gh", "pr", "edit", id, "--body", body }, {
        notify = notify_opts,
        success_label = "Body updated: " .. label,
        failed_label = "Failed to update body: ",
        on_success = pr_mutate_success,
      })
    end)
  elseif action_key == "edit_reviewers" then
    select_reviewers("󰭖 Edit reviewers · " .. pr_num, function(reviewers)
      if reviewers == "" then
        return
      end
      exec_async({ "gh", "pr", "edit", id, "--add-reviewer", reviewers }, {
        notify = notify_opts,
        success_label = "Reviewers updated: " .. label,
        failed_label = "Failed to update reviewers: ",
        on_success = pr_mutate_success,
      })
    end)
  elseif action_key == "close" then
    exec_async({ "gh", "pr", "close", id }, {
      notify = notify_opts,
      info_label = "Closing " .. label .. "...",
      success_label = "Closed: " .. label,
      failed_label = "Failed to close: ",
      on_success = pr_mutate_success,
    })
  elseif action_key == "to_draft" then
    exec_async({ "gh", "pr", "ready", id, "--undo" }, {
      notify = notify_opts,
      success_label = "Converted to draft: " .. label,
      failed_label = "Failed to convert to draft: ",
      on_success = pr_mutate_success,
    })
  elseif action_key == "ready" then
    exec_async({ "gh", "pr", "ready", id }, {
      notify = notify_opts,
      success_label = "Marked ready for review: " .. label,
      failed_label = "Failed to mark ready: ",
      on_success = pr_mutate_success,
    })
  elseif action_key == "request_changes" then
    prompt_body({}, function(body)
      if body == "" then
        return
      end
      exec_async({ "gh", "pr", "review", id, "--request-changes", "--body", body }, {
        notify = notify_opts,
        success_label = "Requested changes: " .. label,
        failed_label = "Failed to request changes: ",
        on_success = pr_mutate_success,
      })
    end)
  elseif action_key == "checks" then
    -- Stream CI status in a terminal; gh --watch blocks until checks settle.
    utils.term_cmd("gh pr checks " .. id .. " --watch")
  elseif action_key == "add_label" then
    custom_input("  Labels ", {}, function(lbl)
      if not lbl or lbl == "" then
        return
      end
      exec_async({ "gh", "pr", "edit", id, "--add-label", lbl }, {
        notify = notify_opts,
        success_label = "Label(s) added: " .. label,
        failed_label = "Failed to add label: ",
        on_success = pr_mutate_success,
      })
    end)
  elseif action_key == "reopen" then
    exec_async({ "gh", "pr", "reopen", id }, {
      notify = notify_opts,
      success_label = "Reopened: " .. label,
      failed_label = "Failed to reopen: ",
      on_success = pr_mutate_success,
    })
  elseif action_key == "copy_url" then
    vim.fn.setreg("+", pr.url)
    vim.notify("Copied: " .. pr.url, vim.log.levels.INFO, notify_opts)
  end
end

-- Fetch unresolved comment count, then show action submenu.
local function show_pr_actions(pr)
  vim.system({ "gh", "pr", "view", tostring(pr.number), "--json", "reviewThreads" }, {}, function(result)
    vim.schedule(function()
      local unresolved = 0

      if result.code == 0 then
        local ok, data = pcall(vim.json.decode, result.stdout or "{}")

        if ok and data and data.reviewThreads then
          for _, t in ipairs(data.reviewThreads) do
            if not t.isResolved and not t.isOutdated then
              unresolved = unresolved + 1
            end
          end
        end
      end

      local merge_icon = MERGE_STATE_ICONS[pr.mergeStateStatus or ""] or "?"
      local unresolved_str = unresolved > 0 and (" · " .. unresolved .. " unresolved 󰅺") or ""
      local title = string.format(" #%d · %s %s%s", pr.number, merge_icon, pr.mergeStateStatus or "?", unresolved_str)

      local title_hl = PR_STATE_HLS[pr.mergeStateStatus or ""] or "DiagnosticInfo"
      if pr.isDraft then
        title_hl = "Comment"
      end

      local labels_str = #pr.labels > 0
          and table.concat(
            vim.tbl_map(function(l)
              return l.name
            end, pr.labels),
            ", "
          )
        or "—"

      local pr_preview = string.format(
        "# #%d %s\n\n**Author:** %s  **Branch:** `%s` → `%s`\n**Merge:** %s  **Review:** %s\n**Labels:** %s\n**+%d -%d** (%d files)\n\n---\n\n%s",
        pr.number,
        pr.title,
        pr.author.login,
        pr.headRefName,
        pr.baseRefName,
        pr.mergeStateStatus or "UNKNOWN",
        pr.reviewDecision or "none",
        labels_str,
        pr.additions,
        pr.deletions,
        pr.changedFiles,
        pr.body ~= "" and pr.body or "_No description_"
      )

      local items = {}
      for _, a in ipairs(PR_ACTIONS) do
        table.insert(items, {
          text = a.text,
          key = a.key,
          hl = a.hl,
          preview = { text = pr_preview, ft = "markdown" },
        })
      end

      snacks.picker.pick({
        finder = function()
          return items
        end,
        format = function(item, _)
          return { { item.text, item.hl or "Normal" } }
        end,
        preview = "preview",
        layout = custom_layout({
          title = { { title, title_hl } },
          width = 0.8,
          height = 0.65,
          preview = true,
        }),
        confirm = function(picker, item)
          picker:close()

          if item then
            vim.schedule(function()
              handle_pr_action(item.key, pr)
            end)
          end
        end,
      })
    end)
  end)
end

local function open_gh_pr()
  local f = PR_FILTERS[pr_filter_idx]

  get_gh_prs(f, function(prs)
    if not prs then
      return
    end

    local items = format_pr_items(prs)

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        local pr = item._pr

        local status_hl = PR_STATE_HLS[pr.mergeStateStatus or ""] or "Comment"

        if pr.isDraft then
          status_hl = "Comment"
        end

        local review_hl = PR_REVIEW_HLS[pr.reviewDecision or ""] or "Comment"

        local draft_icon = pr.isDraft and " " or " "
        local review_icon = REVIEW_DECISION_ICONS[pr.reviewDecision] or " "
        local merge_icon = MERGE_STATE_ICONS[pr.mergeStateStatus] or "?"

        return {
          { draft_icon .. " ", status_hl },
          { merge_icon .. " ", status_hl },
          { string.format("%-5d ", pr.number), "DiagnosticInfo" },
          { string.format("%-55s  ", pr.title:sub(1, 55)), "Normal" },
          { review_icon .. " ", review_hl },
          { " " .. pr.author.login:sub(1, 25), "Function" },
        }
      end,
      preview = "preview",
      layout = custom_layout({
        title = { { "  PRs · " .. f.name, "DiagnosticInfo" } },
        fullscreen = true,
        preview = true,
        preview_ratio = 0.5,
      }),
      actions = {
        cycle_filter = function(picker)
          pr_filter_idx = pr_filter_idx % #PR_FILTERS + 1
          picker:close()
          vim.schedule(open_gh_pr)
        end,
        refresh = make_refresh_action(function()
          cache.invalidate_pattern("gh.prs")
        end, function(cb)
          get_gh_prs(PR_FILTERS[pr_filter_idx], cb)
        end, function(data)
          items = format_pr_items(data)
        end),
      },
      win = {
        input = {
          keys = {
            ["<C-o>"] = { "cycle_filter", mode = { "i", "n" }, desc = "Cycle PR filter" },
            ["<C-k>"] = { "refresh", mode = { "i", "n" }, desc = "Refresh PRs" },
          },
        },
      },
      confirm = function(picker, item)
        picker:close()

        if item then
          vim.schedule(function()
            show_pr_actions(item._pr)
          end)
        end
      end,
    })
  end)
end

function M.gh_pr_picker()
  open_gh_pr()
end

function M.gh_switch_account()
  if not cache.is_cached("gh.accounts") then
    vim.notify("Loading github accounts...", vim.log.levels.INFO, notify_opts)
  end

  get_gh_accounts(function(accounts)
    if not accounts then
      return
    end

    -- Use cached current login to exclude from the list
    fetch_current_login(function(current_login)
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
        format = function(item, _)
          return { { item.text, "Function" } }
        end,
        layout = custom_layout({
          title = { { "  GH Account (" .. current_login .. ") ", "DiagnosticWarn" } },
          width = 0.3,
        }),
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
            on_success = function()
              cache.invalidate({ "gh.current_login" })
              cache.invalidate_pattern("gh.prs")
              cache.invalidate_pattern("gh.collaborators")
              fetch_collaborators(function() end)
            end,
          })
        end,
      })
    end)
  end)
end

function M.create_pr()
  local function create_pr_with_gh(data)
    local head_branch = vim.b.gitsigns_head or vim.fn.system("git branch --show-current"):gsub("\n", "")
    local args = { "gh", "pr", "create", "--base", data.base, "--head", head_branch, "--title", data.title }

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

    local cmd_str = table.concat(args, " ")

    with_ssh_passphrase(function(env, cleanup)
      exec_async({ "git", "push", "-u", "origin", "HEAD" }, {
        notify = notify_opts,
        env = env,
        suppress_notify = true,
        failed_label = "Failed to push branch: ",
        on_success = function()
          vim.notify("PR Creating...", vim.log.levels.INFO, notify_opts)
          cleanup()

          exec_async(args, {
            notify = notify_opts,
            success_label = "PR created successfully: ",
            failed_label = "Failed to create PR: ",
            on_success = function()
              vim.cmd("stopinsert")
              cache.evict_pattern("gh.prs")
            end,
            on_failure = function()
              vim.notify("Command:\n" .. cmd_str, vim.log.levels.WARN, notify_opts)
            end,
          })
        end,
        on_failure = cleanup,
      })
    end)
  end

  step_chain({
    function(d, next)
      fetch_current_login(function(current_login)
        local title = current_login ~= "" and ("  Select base branch (" .. current_login .. ") ")
          or "  Select base branch "
        branch_picker({
          title = title,
          exclude_current = true,
          on_confirm = function(base)
            d.base = base
            next(d)
          end,
        })
      end)
    end,
    function(d, next)
      vim.system({ "git", "log", "-1", "--pretty=%s" }, {}, function(result)
        vim.schedule(function()
          local default_title = result.code == 0 and vim.trim(result.stdout or "") or ""
          custom_input("  PR Title ", { default = default_title, width_frac = 0.5 }, function(title)
            if title and title ~= "" then
              d.title = title
              next(d)
            end
          end)
        end)
      end)
    end,
    function(d, next)
      prompt_body({}, function(body)
        d.body = body
        next(d)
      end)
    end,
    function(d, next)
      select_reviewers(" 󰭖 Select reviewers ", function(reviewers)
        d.reviewers = reviewers
        next(d)
      end)
    end,
    function(d, next)
      custom_input("  Label ", {}, function(label)
        d.label = label or ""
        next(d)
      end)
    end,
    function(d, _)
      create_pr_with_gh(d)
    end,
  }, { assignee = "@me", base = nil, title = nil, body = nil, reviewers = "", label = "" })
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
  branch_picker({
    title = "  Select branch ",
    on_confirm = function(branch)
      exec_async({ "git", "checkout", branch }, {
        notify = notify_opts,
        success_label = "Checked out " .. branch,
        failed_label = "Failed to checkout branch: ",
      })
    end,
  })
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

  custom_input("  New branch name ", {}, on_input)
end

function M.git_delete_branch()
  branch_picker({
    title = "  Delete branch ",
    title_hl = "DiagnosticError",
    exclude_current = true,
    format = function(item, _)
      local parts = vim.split(item.text, "/")
      if #parts > 1 then
        local prefix = table.concat({ unpack(parts, 1, #parts - 1) }, "/") .. "/"
        return {
          { prefix, "Comment" },
          { parts[#parts], "DiagnosticError" },
        }
      end
      return { { item.text, "DiagnosticError" } }
    end,
    on_confirm = function(branch)
      exec_async({ "git", "branch", "-d", branch }, {
        notify = notify_opts,
        success_label = "Deleted " .. branch,
        failed_label = "Failed to delete branch (use -D to force): ",
        on_success = function()
          vim.schedule(M.git_delete_branch)
        end,
      })
    end,
  })
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

    vim.ui.select(commits, { prompt = " Select commit to cherry-pick: " }, on_commit_selected)
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
  vim.cmd("DiffviewFileHistory " .. vim.fn.fnameescape(current_file))
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

function M.git_stash_apply()
  stash_picker("Apply stash", function(item)
    exec_async({ "git", "stash", "apply", item.ref }, {
      notify = notify_opts,
      success_label = "Stash applied: " .. item.ref,
      failed_label = "Failed to apply stash: ",
    })
  end, "DiagnosticOk")
end

function M.git_stash_drop()
  stash_picker("Drop stash", function(item)
    exec_async({ "git", "stash", "drop", item.ref }, {
      notify = notify_opts,
      success_label = "Stash dropped: " .. item.ref,
      failed_label = "Failed to drop stash: ",
      on_success = function()
        vim.schedule(M.git_stash_drop)
      end,
    })
  end, "DiagnosticError")
end

local function reset_picker(title, title_hl, on_confirm)
  get_recent_commits(30)(function(commits)
    if not commits then
      return
    end

    local items = {}

    for _, line in ipairs(commits) do
      table.insert(items, { text = line, _hash = line:match("^(%S+)") })
    end

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        if item._hash == "HEAD" then
          return { { item.text, "DiagnosticWarn" } }
        end

        local hash, rest = item.text:match("^(%S+)%s+(.*)$")

        return {
          { (hash or item.text) .. " ", "DiagnosticInfo" },
          { rest or "", "Normal" },
        }
      end,
      layout = custom_layout({
        title = { { title, title_hl } },
        width = 0.55,
      }),
      confirm = function(picker, item)
        picker:close()

        if item then
          on_confirm(item._hash)
        end
      end,
    })
  end)
end

function M.git_reset_hard()
  reset_picker(" Reset --hard", "DiagnosticError", function(hash)
    utils.confirm_dangerous("  git reset --hard " .. hash .. "?", function()
      exec_async({ "git", "reset", "--hard", hash }, {
        notify = notify_opts,
        success_label = "Hard reset to " .. hash .. " successful",
        failed_label = "Hard reset failed: ",
      })
    end)
  end)
end

function M.git_reset_to_branch()
  branch_picker({
    title = " Reset --hard to branch",
    title_hl = "DiagnosticError",
    exclude_current = true,
    on_confirm = function(branch)
      utils.confirm_dangerous("  git reset --hard " .. branch .. "?", function()
        exec_async({ "git", "reset", "--hard", branch }, {
          notify = notify_opts,
          success_label = "Hard reset to " .. branch .. " successful",
          failed_label = "Hard reset failed: ",
        })
      end)
    end,
  })
end

function M.git_reset_soft()
  reset_picker(" Reset --soft", "DiagnosticWarn", function(hash)
    exec_async({ "git", "reset", "--soft", hash }, {
      notify = notify_opts,
      success_label = "Soft reset to " .. hash .. " successful",
      failed_label = "Soft reset failed: ",
    })
  end)
end

function M.git_restore_staged()
  exec_async({ "git", "restore", "--staged", "." }, {
    notify = notify_opts,
    success_label = "Restored successful",
    failed_label = "Restore failed",
  })
end

function M.git_restore_all()
  utils.confirm_dangerous(" 󰅝 git clean -f + checkout ?", function()
    exec_async({ "git", "clean", "-f" }, {
      notify = notify_opts,
      suppress_notify = true,
      failed_label = "Failed to clean: ",
      on_success = function()
        exec_async({ "git", "checkout", "." }, {
          notify = notify_opts,
          success_label = "Git cleaned",
          failed_label = "Failed to checkout: ",
        })
      end,
    })
  end)
end

function M.git_pull()
  with_ssh_passphrase(function(env, cleanup)
    exec_async({ "git", "pull" }, {
      notify = notify_opts,
      env = env,
      info_label = "Pulling...",
      success_label = "Pull successful",
      failed_label = "Pull failed: ",
      on_success = cleanup,
      on_failure = cleanup,
    })
  end)
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

  with_ssh_passphrase(function(env, cleanup)
    exec_async(push_args, {
      notify = notify_opts,
      env = env,
      info_label = "Pushing to: " .. branch .. "...",
      success_label = "Pushed to: " .. branch,
      failed_label = "Failed to push: ",
      on_success = cleanup,
      on_failure = cleanup,
    })
  end)
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
            -- Intentional: always push after commit. Amend passes force=true → git push --force.
            -- Uses --force (not --force-with-lease) by design; acceptable on personal branches.
            M.git_push(amend)
          end,
        })
      end)
    end
  end

  custom_input(
    amend and "  Amend commit " or "  Commit to " .. branch .. " ",
    { default = default_msg },
    on_input
  )
end

function M.git_commit_amend()
  M.git_commit(true)
end

function M.git_diff_branch()
  branch_picker({
    title = "  Diff branch ",
    on_confirm = function(branch)
      vim.cmd("DiffviewOpen " .. vim.fn.fnameescape(branch))
    end,
  })
end

function M.git_fetch()
  with_ssh_passphrase(function(env, cleanup)
    exec_async({ "git", "fetch", "--prune" }, {
      notify = notify_opts,
      env = env,
      info_label = "Fetching (prune)...",
      success_label = "Fetched and pruned remote-tracking refs",
      failed_label = "Fetch failed: ",
      on_success = cleanup,
      on_failure = cleanup,
    })
  end)
end

function M.git_merge_branch()
  branch_picker({
    title = "  Merge branch ",
    exclude_current = true,
    on_confirm = function(branch)
      exec_async({ "git", "merge", branch }, {
        notify = notify_opts,
        info_label = "Merging " .. branch .. "...",
        success_label = "Merged " .. branch,
        failed_label = "Merge failed (resolve conflicts): ",
      })
    end,
  })
end

-- Line blame for the cursor position — lightweight notify, no extra window.
function M.git_blame()
  local file = vim.fn.expand("%:.")

  if file == "" then
    vim.notify("No file in buffer", vim.log.levels.WARN, notify_opts)
    return
  end

  local line = vim.fn.line(".")

  vim.system({ "git", "blame", "-L", line .. "," .. line, "--", file }, {}, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        vim.notify("Blame failed: " .. (res.stderr or "unknown error"), vim.log.levels.ERROR, notify_opts)
        return
      end

      vim.notify(vim.trim(res.stdout or ""), vim.log.levels.INFO, notify_opts)
    end)
  end)
end

-- ── Commit log browser ────────────────────────────────────────────────────────

local COMMIT_ACTIONS = {
  { text = " View diff", key = "diff", hl = HL.info },
  { text = " Copy hash", key = "copy", hl = HL.info },
  { text = "󰿄 Checkout", key = "checkout", hl = HL.ok },
  { text = " Cherry-pick", key = "cherry", hl = HL.warn },
  { text = " Revert", key = "revert", hl = HL.warn },
  { text = "󰑓 Reset --hard here", key = "reset_hard", hl = HL.err },
}

local function handle_commit_action(action_key, hash)
  if action_key == "diff" then
    -- `<hash>^!` is git shorthand for "this commit vs its parent".
    vim.cmd("DiffviewOpen " .. hash .. "^!")
  elseif action_key == "copy" then
    vim.fn.setreg("+", hash)
    vim.notify("Copied: " .. hash, vim.log.levels.INFO, notify_opts)
  elseif action_key == "checkout" then
    exec_async({ "git", "checkout", hash }, {
      notify = notify_opts,
      success_label = "Checked out " .. hash,
      failed_label = "Failed to checkout: ",
    })
  elseif action_key == "cherry" then
    exec_async({ "git", "cherry-pick", hash }, {
      notify = notify_opts,
      info_label = "Cherry-picking " .. hash .. "...",
      success_label = "Cherry-picked " .. hash,
      failed_label = "Failed to cherry-pick: ",
    })
  elseif action_key == "revert" then
    exec_async({ "git", "revert", hash, "--no-edit" }, {
      notify = notify_opts,
      success_label = "Reverted " .. hash,
      failed_label = "Failed to revert: ",
    })
  elseif action_key == "reset_hard" then
    utils.confirm_dangerous(" 󱄌 git reset --hard " .. hash .. "?", function()
      exec_async({ "git", "reset", "--hard", hash }, {
        notify = notify_opts,
        success_label = "Reset --hard to " .. hash,
        failed_label = "Failed to reset: ",
      })
    end)
  end
end

function M.git_log()
  get_recent_commits(50)(function(commits)
    if not commits then
      return
    end

    local items = {}

    for _, line in ipairs(commits) do
      table.insert(items, { text = line, _hash = line:match("^(%S+)") })
    end

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        local hash, rest = item.text:match("^(%S+)%s+(.*)$")
        return {
          { (hash or item.text) .. " ", "DiagnosticInfo" },
          { rest or "", "Normal" },
        }
      end,
      layout = custom_layout({
        title = { { "  Commit log ", "DiagnosticInfo" } },
        width = 0.8,
      }),
      confirm = function(picker, item)
        picker:close()

        if item and item._hash then
          vim.schedule(function()
            utils.menu_picker(COMMIT_ACTIONS, function(a)
              handle_commit_action(a.key, item._hash)
            end, {
              title = "  Commit " .. item._hash,
              height = 0.4,
            })
          end)
        end
      end,
    })
  end)
end

-- Warm GH-related caches in background (called on SessionLoadPost).
-- Fires all three network fetches concurrently with no-op callbacks.
function M.warm_gh_cache()
  get_gh_accounts(function() end)
  fetch_current_login(function() end)
  fetch_collaborators(function() end)
end

return M
