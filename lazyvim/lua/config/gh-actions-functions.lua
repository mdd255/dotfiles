local exec_async = require("config.utils").exec_async
local term_cmd = require("config.utils").term_cmd
local snacks = require("snacks")
local M = {}

local notify_opts = { title = "GH Actions" }

local function picker_width(fraction, min_cols)
  local ui = vim.api.nvim_list_uis()[1] or { width = 120 }
  return math.max(min_cols or 60, math.floor(ui.width * fraction))
end

-- ── Filters ───────────────────────────────────────────────────────────────────

local RUN_FILTERS = {
  { name = "Running", status = "in_progress" },
  { name = "Recent", status = nil },
  { name = "Failed", status = "failure" },
}

local run_filter_idx = 1

-- ── Status / conclusion icons ──────────────────────────────────────────────────

local CONCLUSION_ICONS = {
  success = "✓",
  failure = "✗",
  cancelled = "⊘",
  skipped = "–",
  timed_out = "⏱",
  action_required = "!",
  startup_failure = "✗",
  neutral = "~",
  stale = "~",
}

local STATUS_ICONS = {
  in_progress = "⟳",
  queued = "◌",
  waiting = "◌",
  requested = "◌",
  pending = "◌",
  completed = "✓",
}

local function run_icon(run)
  local conclusion = run.conclusion
  if conclusion and conclusion ~= "" and conclusion ~= vim.NIL then
    return CONCLUSION_ICONS[conclusion] or "?"
  end
  return STATUS_ICONS[run.status] or "?"
end

-- ── Fetch runs ────────────────────────────────────────────────────────────────

local function get_gh_runs(filter, callback)
  local cmd = {
    "gh",
    "run",
    "list",
    "--limit",
    "30",
    "--json",
    "databaseId,displayTitle,headBranch,status,conclusion,workflowName,actor,event,createdAt,updatedAt,number,headSha,pullRequests,startedAt",
  }

  if filter.status then
    vim.list_extend(cmd, { "--status", filter.status })
  end

  vim.system(cmd, {}, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Failed to list runs: " .. (result.stderr or ""), vim.log.levels.ERROR, notify_opts)
        callback(nil)
        return
      end

      local ok, data = pcall(vim.json.decode, result.stdout or "[]")

      if not ok or type(data) ~= "table" then
        vim.notify("Failed to parse run list", vim.log.levels.ERROR, notify_opts)
        callback(nil)
        return
      end

      callback(data)
    end)
  end)
end

-- ── Preview text ──────────────────────────────────────────────────────────────

local function run_preview(run)
  local actor_login = (type(run.actor) == "table") and (run.actor.login or "") or ""

  local pr_str = ""
  local base_branch = ""

  if type(run.pullRequests) == "table" and #run.pullRequests > 0 then
    local nums = {}
    for _, pr in ipairs(run.pullRequests) do
      table.insert(nums, "#" .. tostring(pr.number or "?"))
    end
    pr_str = table.concat(nums, ", ")
    base_branch = run.pullRequests[1].baseRef or ""
  end

  local conclusion = run.conclusion
  local status_str = run.status or ""
  if conclusion and conclusion ~= "" and conclusion ~= vim.NIL then
    status_str = status_str .. " / " .. conclusion
  end

  return table.concat({
    "Workflow:    " .. (run.workflowName or ""),
    "Title:       " .. (run.displayTitle or ""),
    "Event:       " .. (run.event or ""),
    "Status:      " .. status_str,
    "Author:      " .. actor_login,
    "Head branch: " .. (run.headBranch or ""),
    "Base branch: " .. base_branch,
    "PR:          " .. pr_str,
    "Run #:       " .. tostring(run.number or ""),
    "Run ID:      " .. tostring(run.databaseId or ""),
    "SHA:         " .. ((run.headSha or ""):sub(1, 10)),
    "Created:     " .. (run.createdAt or ""),
    "Updated:     " .. (run.updatedAt or ""),
  }, "\n")
end

-- ── Confirmation prompt ───────────────────────────────────────────────────────

---Prompt user to type "yes" before executing a dangerous action.
---@param prompt string
---@param on_confirm function
local function confirm_dangerous(prompt, on_confirm)
  snacks.input({ prompt = prompt .. "  Type yes to confirm: " }, function(input)
    if input and input:lower() == "yes" then
      on_confirm()
    else
      vim.notify("Action cancelled", vim.log.levels.INFO, notify_opts)
    end
  end)
end

-- ── Actions ───────────────────────────────────────────────────────────────────

local RUN_ACTIONS = {
  { text = "re-run", key = "rerun" },
  { text = "re-run failed jobs", key = "rerun_failed" },
  { text = "view log", key = "view_log" },
  { text = "view log (failed)", key = "view_log_failed" },
  { text = "watch live", key = "watch" },
  { text = "view jobs", key = "view_jobs" },
  { text = "open in browser", key = "browser" },
  { text = "download artifacts", key = "download" },
  { text = "copy run ID", key = "copy_id" },
  { text = "cancel  ⚠", key = "cancel" },
  { text = "delete  ⚠", key = "delete" },
}

local function run_action(action_key, run)
  if not run then
    return
  end

  local id = tostring(run.databaseId)
  local label = "#" .. id .. " (" .. (run.workflowName or "") .. ")"

  if action_key == "rerun" then
    exec_async({ "gh", "run", "rerun", id }, {
      notify = notify_opts,
      info_label = "Re-running " .. label .. "...",
      success_label = "Re-run triggered: " .. label,
      failed_label = "Failed to re-run: ",
    })
  elseif action_key == "rerun_failed" then
    exec_async({ "gh", "run", "rerun", "--failed", id }, {
      notify = notify_opts,
      info_label = "Re-running failed jobs for " .. label .. "...",
      success_label = "Re-run failed jobs triggered: " .. label,
      failed_label = "Failed to re-run failed jobs: ",
    })
  elseif action_key == "view_log" then
    term_cmd("gh run view " .. id .. " --log 2>&1 | less -R")
  elseif action_key == "view_log_failed" then
    term_cmd("gh run view " .. id .. " --log-failed 2>&1 | less -R")
  elseif action_key == "watch" then
    term_cmd("gh run watch " .. id)
  elseif action_key == "view_jobs" then
    term_cmd("gh run view " .. id .. " 2>&1 | less")
  elseif action_key == "browser" then
    exec_async({ "gh", "run", "view", id, "--web" }, {
      notify = notify_opts,
      supress_notify = true,
      failed_label = "Failed to open browser: ",
    })
  elseif action_key == "download" then
    snacks.input({ prompt = "Download dir: ", default = "." }, function(dir)
      local target = (dir and dir ~= "") and dir or "."
      exec_async({ "gh", "run", "download", id, "-D", target }, {
        notify = notify_opts,
        info_label = "Downloading artifacts for " .. label .. "...",
        success_label = "Artifacts downloaded to " .. target,
        failed_label = "Failed to download artifacts: ",
      })
    end)
  elseif action_key == "copy_id" then
    vim.fn.setreg("+", id)
    vim.notify("Copied: " .. id, vim.log.levels.INFO, notify_opts)
  elseif action_key == "cancel" then
    confirm_dangerous("Cancel run " .. label .. "?", function()
      exec_async({ "gh", "run", "cancel", id }, {
        notify = notify_opts,
        info_label = "Cancelling " .. label .. "...",
        success_label = "Cancelled: " .. label,
        failed_label = "Failed to cancel: ",
      })
    end)
  elseif action_key == "delete" then
    confirm_dangerous("Permanently DELETE run " .. label .. "?", function()
      exec_async({ "gh", "run", "delete", id }, {
        notify = notify_opts,
        info_label = "Deleting " .. label .. "...",
        success_label = "Deleted: " .. label,
        failed_label = "Failed to delete: ",
      })
    end)
  end
end

-- ── Action submenu picker ──────────────────────────────────────────────────────

local function show_action_picker(run)
  local items = {}

  for _, a in ipairs(RUN_ACTIONS) do
    table.insert(items, { text = a.text, key = a.key })
  end

  snacks.picker.pick({
    finder = function()
      return items
    end,
    format = "text",
    layout = {
      layout = {
        title = "  Action",
        box = "vertical",
        position = "float",
        width = picker_width(0.22, 40),
        height = 0.55,
        border = "rounded",
        { win = "input", height = 1, border = "bottom" },
        { win = "list" },
      },
    },
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          run_action(item.key, run)
        end)
      end
    end,
  })
end

-- ── Main picker ────────────────────────────────────────────────────────────────

local function open_actions_picker()
  local f = RUN_FILTERS[run_filter_idx]
  vim.notify("Loading runs (" .. f.name .. ")...", vim.log.levels.INFO, notify_opts)

  get_gh_runs(f, function(runs)
    if not runs then
      return
    end

    local items = {}

    for _, run in ipairs(runs) do
      local icon = run_icon(run)
      local actor_login = (type(run.actor) == "table") and (run.actor.login or "") or ""
      local pr_str = ""

      if type(run.pullRequests) == "table" and #run.pullRequests > 0 then
        pr_str = "PR#" .. tostring(run.pullRequests[1].number or "")
      end

      table.insert(items, {
        text = string.format(
          "%s %-28s %-18s %-14s %-12s %s",
          icon,
          (run.workflowName or ""):sub(1, 28),
          (run.headBranch or ""):sub(1, 18),
          (run.status or ""):sub(1, 14),
          actor_login:sub(1, 12),
          pr_str
        ),
        _run = run,
        preview = { text = run_preview(run), ft = "text" },
      })
    end

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = "text",
      preview = "preview",
      layout = {
        layout = {
          title = "  Actions · " .. f.name,
          box = "vertical",
          position = "float",
          width = picker_width(0.9, 110),
          height = 0.75,
          border = "rounded",
          { win = "input", height = 1, border = "bottom" },
          {
            box = "horizontal",
            { win = "list", width = 0.55 },
            { win = "preview", border = "left" },
          },
        },
      },
      actions = {
        cycle_filter = function(picker)
          run_filter_idx = run_filter_idx % #RUN_FILTERS + 1
          picker:close()
          vim.schedule(open_actions_picker)
        end,
      },
      win = {
        input = {
          keys = {
            ["<C-o>"] = {
              "cycle_filter",
              mode = { "i", "n" },
              desc = "Cycle filter (Running → Recent → Failed)",
            },
          },
        },
      },
      confirm = function(picker, item)
        picker:close()
        if not item then
          return
        end
        vim.schedule(function()
          show_action_picker(item._run)
        end)
      end,
    })
  end)
end

function M.gh_actions_picker()
  open_actions_picker()
end

return M
