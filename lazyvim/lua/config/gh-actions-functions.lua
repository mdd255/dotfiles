local utils = require("config.utils")
local exec_async = utils.exec_async
local term_cmd = utils.term_cmd
local picker_width = utils.picker_width
local snacks = require("snacks")
local M = {}

local cache = require("config.cache")
local CACHE_TTL_MS = 300000 -- 5 min in ms

local notify_opts = { title = "GH Actions" }

-- ── Filters ───────────────────────────────────────────────────────────────────

local RUN_FILTERS = {
  { name = "Recent", status = nil },
  { name = "Running", status = "in_progress" },
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
  in_progress = "󱦟",
  queued = "",
  waiting = "",
  requested = "",
  pending = "",
  completed = "",
}

local CONCLUSION_HLS = {
  success = "DiagnosticOk",
  failure = "DiagnosticError",
  cancelled = "DiagnosticWarn",
  skipped = "Comment",
  timed_out = "DiagnosticError",
  action_required = "DiagnosticWarn",
  startup_failure = "DiagnosticError",
  neutral = "Comment",
  stale = "Comment",
}

local function run_status_icon(run)
  local status = run.status

  if status and status ~= "" and status ~= vim.NIL then
    return STATUS_ICONS[status] or "?"
  end

  return "?"
end

-- gh `--json` fields can be missing or JSON null (decoded to vim.NIL); coerce to
-- a safe string before :sub() to avoid nil-index crashes on odd runs.
local function safe_str(v)
  if v == nil or v == vim.NIL then
    return "N/A"
  end
  return tostring(v)
end

local function run_icon(run)
  local conclusion = run.conclusion

  if conclusion and conclusion ~= "" and conclusion ~= vim.NIL then
    return CONCLUSION_ICONS[conclusion] or "?"
  end

  return STATUS_ICONS[run.status] or "?"
end

-- ── Fetch runs ────────────────────────────────────────────────────────────────

-- Raw async fetcher factory for a given filter (no cache logic here).
local function make_runs_fetcher(filter)
  return function(callback)
    local cmd = {
      "gh",
      "run",
      "list",
      "--limit",
      "30",
      "--json",
      "databaseId,displayTitle,headBranch,status,conclusion,workflowName,event,createdAt,updatedAt,number,headSha,startedAt",
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
end

-- One cache.wrap entry per filter — inflight deduplication + TTL per filter key.
local gh_runs_fetchers = {}

for _, f in ipairs(RUN_FILTERS) do
  local key = "gh.runs." .. (f.status or "recent")
  gh_runs_fetchers[f.status or "recent"] = cache.wrap(key, CACHE_TTL_MS, make_runs_fetcher(f))
end

local function get_gh_runs(filter, callback)
  local key = filter.status or "recent"

  if not cache.is_cached("gh.runs." .. key) then
    vim.notify("Loading runs...", vim.log.levels.INFO, notify_opts)
  end

  gh_runs_fetchers[key](callback)
end

-- ── Preview text ──────────────────────────────────────────────────────────────

local function run_preview(run)
  local conclusion = run.conclusion
  local status_str = run.status or ""

  if conclusion and conclusion ~= "" and conclusion ~= vim.NIL then
    status_str = status_str .. " / " .. conclusion
  end

  return table.concat({
    "number:   " .. tostring(run.number),
    "id:       " .. tostring(run.databaseId),
    "title:    " .. (run.displayTitle or "N/A"),
    "workflow: " .. (run.workflowName or "N/A"),
    -- safe_str everywhere: gh --json fields can be missing or vim.NIL (null),
    -- and raw concat against vim.NIL throws.
    "branch:   " .. safe_str(run.headBranch),
    "event:    " .. (run.event or "N/A"),
    "status:   " .. status_str,
    "sha:      " .. ((run.headSha and run.headSha ~= vim.NIL) and run.headSha:sub(1, 10) or "N/A"),
    "created:  " .. safe_str(run.createdAt),
    "updated:  " .. safe_str(run.updatedAt),
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
  { text = "cancel  ⚠", key = "cancel" },
  { text = "delete  ⚠", key = "delete" },
}

local function run_mutate_success()
  cache.invalidate_pattern("gh.runs")
end

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
      on_success = run_mutate_success,
    })
  elseif action_key == "rerun_failed" then
    exec_async({ "gh", "run", "rerun", "--failed", id }, {
      notify = notify_opts,
      info_label = "Re-running failed jobs for " .. label .. "...",
      success_label = "Re-run failed jobs triggered: " .. label,
      failed_label = "Failed to re-run failed jobs: ",
      on_success = run_mutate_success,
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
      suppress_notify = true,
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
  elseif action_key == "cancel" then
    confirm_dangerous("Cancel run " .. label .. "?", function()
      exec_async({ "gh", "run", "cancel", id }, {
        notify = notify_opts,
        info_label = "Cancelling " .. label .. "...",
        success_label = "Cancelled: " .. label,
        failed_label = "Failed to cancel: ",
        on_success = function()
          cache.invalidate_pattern("gh.runs")
        end,
      })
    end)
  elseif action_key == "delete" then
    confirm_dangerous("Permanently DELETE run " .. label .. "?", function()
      exec_async({ "gh", "run", "delete", id }, {
        notify = notify_opts,
        info_label = "Deleting " .. label .. "...",
        success_label = "Deleted: " .. label,
        failed_label = "Failed to delete: ",
        on_success = function()
          cache.invalidate_pattern("gh.runs")
        end,
      })
    end)
  end
end

-- ── Action submenu picker ──────────────────────────────────────────────────────

local function show_action_picker(run)
  snacks.picker.pick({
    finder = function()
      return RUN_ACTIONS
    end,
    format = function(item, _)
      local danger = { cancel = true, delete = true }
      local hl = danger[item.key] and "DiagnosticError" or "Text"
      return { { item.text, hl } }
    end,
    layout = {
      layout = {
        title = { { "  Action", "DiagnosticInfo" } },
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

  get_gh_runs(f, function(runs)
    if not runs then
      return
    end

    local items = {}

    for _, run in ipairs(runs) do
      local conclusion_icon = run_icon(run)
      local status_icon = run_status_icon(run)

      table.insert(items, {
        text = string.format(
          "%s %-28s %s   %-18s %s",
          conclusion_icon,
          safe_str(run.displayTitle):sub(1, 26),
          status_icon,
          safe_str(run.headBranch):sub(1, 15),
          safe_str(run.startedAt)
        ),
        _run = run,
        preview = { text = run_preview(run), ft = "yaml" },
      })
    end

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        local run = item._run
        local conclusion = run.conclusion
        local hl = (conclusion and conclusion ~= "" and conclusion ~= vim.NIL)
            and (CONCLUSION_HLS[conclusion] or "Text")
          or "DiagnosticInfo"
        local icon_col = run_icon(run) .. " "
        local title_col = string.format("%-28s", safe_str(run.displayTitle):sub(1, 26))
        local status_col = run_status_icon(run) .. "   "
        local branch_col = string.format("%-18s", safe_str(run.headBranch):sub(1, 15))
        local date_col = run.startedAt or ""
        return {
          { icon_col, hl },
          { title_col, hl },
          { status_col, "DiagnosticInfo" },
          { branch_col, "Function" },
          { date_col, "Comment" },
        }
      end,
      preview = "preview",
      layout = {
        layout = {
          title = { { "  Actions · " .. f.name, "DiagnosticInfo" } },
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
        refresh = function(picker)
          cache.invalidate_pattern("gh.runs")
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
              desc = "Cycle filter (Recent → Running → Failed)",
            },
            ["<C-k>"] = { "refresh", mode = { "i", "n" }, desc = "Refresh runs" },
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
  run_filter_idx = 1
  open_actions_picker()
end

return M
