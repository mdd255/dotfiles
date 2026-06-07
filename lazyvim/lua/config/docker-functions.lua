local utils = require("config.utils")
local exec_async = utils.exec_async
local term_cmd = utils.term_cmd
local picker_layout = utils.picker_layout
local picker_selection = utils.picker_selection
local parse_json_lines = utils.parse_json_lines
local HL = utils.HL
local float_input = utils.float_input
local select_and_clear_action = utils.select_and_clear_action
local make_refresh_action = utils.make_refresh_action
local cache = require("config.cache")
local snacks = require("snacks")
local M = {}

local notify_opts = { title = "Docker" }

local function format_container_ports(str)
  str = str or "N/A"
  local result = {}
  local seen = {}

  for port in str:gmatch("(%d+/tcp)") do
    if not seen[port] then
      seen[port] = true
      table.insert(result, port)
    end
  end

  local ports = table.concat(result, ", ")
  return ports
end

-- ── Containers ────────────────────────────────────────────────────────────────

-- Forward declarations — referenced in action callbacks before their definitions.
local open_container_picker
local open_image_picker

local function container_mutate_success()
  cache.invalidate_pattern("docker.containers")
  vim.schedule(open_container_picker)
end

local function image_mutate_success()
  cache.invalidate_pattern("docker.images")
  vim.schedule(open_image_picker)
end

local CONTAINER_FILTERS = {
  { name = "All", args = { "-a" } },
  { name = "Running", args = {} },
  { name = "Stopped", args = { "-a", "--filter", "status=exited" } },
}

local CONTAINER_ACTIONS = {
  { text = " exec", key = "exec_bash", hl = HL.ok },
  { text = "󰦪 view logs", key = "view_logs", hl = HL.info },
  { text = " stats", key = "stats", hl = HL.info },
  { text = " stop", key = "stop", hl = HL.warn },
  { text = " start", key = "start", hl = HL.ok },
  { text = " restart", key = "restart", hl = HL.warn },
  { text = "󰏤 pause", key = "pause", hl = HL.warn },
  { text = " unpause", key = "unpause", hl = HL.ok },
  { text = " remove", key = "remove", hl = HL.err },
  { text = "✏ rename", key = "rename", hl = HL.ident },
  { text = " inspect", key = "inspect", hl = HL.info },
  { text = " copy name", key = "copy_name", hl = HL.info },
}

-- Table-driven docker container CLI actions. Each entry produces an
-- exec_async call against the container ID with consistent notify labels.
local CONTAINER_CMD_ACTIONS = {
  stop = { args = { "stop" }, verb = "Stopping", past = "Stopped" },
  start = { args = { "start" }, verb = "Starting", past = "Started" },
  restart = { args = { "restart" }, verb = "Restarting", past = "Restarted" },
  pause = { args = { "pause" }, verb = "Pausing", past = "Paused" },
  unpause = { args = { "unpause" }, verb = "Unpausing", past = "Unpaused" },
  remove = { args = { "rm", "-f" }, verb = "Removing", past = "Removed" },
}

local function run_container_action(action_key, containers)
  local def = CONTAINER_CMD_ACTIONS[action_key]

  if def then
    local function run_all()
      for _, c in ipairs(containers) do
        local args = vim.list_extend({ "docker" }, def.args)
        table.insert(args, c.ID)

        exec_async(args, {
          notify = notify_opts,
          info_label = def.verb .. " " .. c.Names .. "...",
          success_label = def.past .. " " .. c.Names,
          failed_label = "Failed to " .. action_key .. " " .. c.Names .. ": ",
          on_success = container_mutate_success,
        })
      end
    end

    -- `remove` is irreversible (docker rm -f) — gate it behind a yes prompt.
    if action_key == "remove" then
      utils.confirm_dangerous("Remove " .. #containers .. " container(s)?", run_all)
    else
      run_all()
    end

    return
  end

  if action_key == "exec_bash" then
    for _, c in ipairs(containers) do
      term_cmd("docker exec -it " .. vim.fn.shellescape(c.Names) .. " bash")
    end
  elseif action_key == "view_logs" then
    for _, c in ipairs(containers) do
      term_cmd("docker logs -f --tail=100 " .. vim.fn.shellescape(c.Names))
    end
  elseif action_key == "stats" then
    local names = vim.tbl_map(function(c)
      return vim.fn.shellescape(c.Names)
    end, containers)

    term_cmd("docker stats " .. table.concat(names, " "))
  elseif action_key == "inspect" then
    for _, c in ipairs(containers) do
      term_cmd("docker inspect " .. vim.fn.shellescape(c.Names) .. " | less")
    end
  elseif action_key == "rename" then
    for _, c in ipairs(containers) do
      float_input("Rename " .. c.Names .. ":", { default = c.Names }, function(new_name)
        if not new_name or new_name == "" or new_name == c.Names then
          return
        end

        exec_async({ "docker", "rename", c.Names, new_name }, {
          notify = notify_opts,
          success_label = "Renamed " .. c.Names .. " → " .. new_name,
          failed_label = "Failed to rename: ",
          on_success = container_mutate_success,
        })
      end)
    end
  elseif action_key == "copy_name" then
    local names = vim.tbl_map(function(c)
      return c.Names
    end, containers)
    local joined = table.concat(names, "\n")
    vim.fn.setreg("+", joined)
    vim.notify("Copied: " .. joined, vim.log.levels.INFO, notify_opts)
  end
end

local function show_action_picker(selected_containers, action_list, on_action)
  utils.menu_picker(action_list, function(item)
    on_action(item.key, selected_containers)
  end, { height = 0.5 })
end

-- Raw container fetcher (no cache). Used internally by get_containers.
local function fetch_containers_raw(filter_args, callback)
  local cmd = vim.list_extend({ "docker", "ps", "--format", "{{json .}}" }, filter_args)

  vim.system(cmd, {}, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Failed to list containers: " .. (result.stderr or ""), vim.log.levels.ERROR, notify_opts)
        callback(nil)
        return
      end

      callback(parse_json_lines(result.stdout))
    end)
  end)
end

-- Cached container fetchers — one per filter, registered once at load time.
local _container_fetchers = cache.wrap_filters(CONTAINER_FILTERS, 30000, function(f)
  return "docker.containers." .. table.concat(f.args, "_")
end, function(f)
  return function(cb)
    fetch_containers_raw(f.args, cb)
  end
end)

local function get_containers(filter_args, callback)
  local key = "docker.containers." .. table.concat(filter_args, "_")
  _container_fetchers[key](callback)
end

local function container_preview(c)
  return table.concat({
    "ID:          " .. c.ID,
    "Name:        " .. c.Names,
    "Image:       " .. c.Image,
    "Size:        " .. c.Size,
    "Status:      " .. c.Status,
    "State:       " .. c.State,
    "Ports:       " .. c.Ports,
    "Date:        " .. c.RunningFor .. " (" .. c.CreatedAt .. ")",
  }, "\n")
end

open_container_picker = function(filter_idx)
  filter_idx = filter_idx or 1
  local f = CONTAINER_FILTERS[filter_idx]
  local container_key = "docker.containers." .. table.concat(f.args, "_")

  if not cache.is_cached(container_key) then
    vim.notify("Loading containers...", vim.log.levels.INFO, notify_opts)
  end

  local items = {}

  local function populate_items(containers)
    items = {}
    for _, c in ipairs(containers) do
      c.Size = vim.split(c.Size, " ")[1]
      c.Ports = format_container_ports(c.Ports)

      table.insert(items, {
        text = string.format("%-28s %-9s %s", c.Names or c.ID, c.Size, c.Status or ""),
        Names = c.Names,
        ID = c.ID,
        Image = c.Image,
        State = c.State,
        Status = c.Status,
        Ports = c.Ports,
        RunningFor = c.RunningFor,
        CreatedAt = c.CreatedAt,
        Size = c.Size,
        preview = { text = container_preview(c), ft = "yaml" },
      })
    end
  end

  get_containers(f.args, function(containers)
    if not containers then
      return
    end

    populate_items(containers)

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        local state_hl = ({
          running = "DiagnosticOk",
          created = "DiagnosticInfo",
          restarting = "DiagnosticWarn",
          paused = "DiagnosticWarn",
          exited = "Comment",
          removing = "DiagnosticError",
          dead = "DiagnosticError",
        })[item.State] or "Comment"

        local name_col = string.format("%-28s", item.Names or item.ID)
        local size_col = string.format("%-9s", item.Size or "")
        local status_col = item.Status or ""

        return {
          { name_col, state_hl },
          { size_col, "Text" },
          { status_col, "Text" },
        }
      end,
      preview = "preview",
      layout = picker_layout({
        title = { { " Containers · " .. f.name, "DiagnosticInfo" } },
        width_frac = 0.9,
        width_min = 100,
        height = 0.75,
        list_width = 0.45,
      }),
      multi = { "confirm" },
      actions = {
        select_and_clear = select_and_clear_action(),

        cycle_filter = function(picker)
          local next_idx = filter_idx % #CONTAINER_FILTERS + 1
          picker:close()

          vim.schedule(function()
            open_container_picker(next_idx)
          end)
        end,
        refresh = make_refresh_action(function()
          cache.invalidate_pattern("docker.containers")
        end, function(cb)
          get_containers(f.args, cb)
        end, populate_items),
      },
      win = {
        input = {
          keys = {
            ["<Tab>"] = { "select_and_clear", mode = { "i", "n" } },
            ["<C-o>"] = { "cycle_filter", mode = { "i", "n" }, desc = "Cycle filter" },
            ["<C-k>"] = { "refresh", mode = { "i", "n" }, desc = "Refresh containers" },
          },
        },
      },
      confirm = function(picker)
        local selected = picker_selection(picker)
        picker:close()

        if not selected or #selected == 0 then
          return
        end

        vim.schedule(function()
          show_action_picker(selected, CONTAINER_ACTIONS, run_container_action)
        end)
      end,
    })
  end)
end

function M.docker_containers()
  open_container_picker()
end

-- ── Images ────────────────────────────────────────────────────────────────────

local IMAGE_ACTIONS = {
  { text = " run (interactive)", key = "run_interactive", hl = HL.ok },
  { text = " run (detached)", key = "run_detached", hl = HL.ok },
  { text = " remove", key = "remove_force", hl = HL.err },
  { text = "󰓼 tag", key = "tag", hl = HL.ident },
  { text = " inspect", key = "inspect", hl = HL.info },
  { text = "󰋚 history", key = "history", hl = HL.info },
}

-- Display label: short last path segment (registry/namespace stripped) for the
-- picker rows only.
local function image_label(img)
  if img.Repository and img.Repository ~= "<none>" then
    local tag = (img.Tag and img.Tag ~= "<none>") and img.Tag or "latest"
    local labels = vim.split(img.Repository, "/")
    return labels[#labels] .. ":" .. tag
  end

  return img.ID
end

-- Command-safe reference: keep the FULL repository path (registry + namespace)
-- so `docker run/tag/history` resolve. `myorg/img` or `ghcr.io/org/img` must not
-- be truncated to the last segment. Falls back to the image ID when untagged.
local function image_ref(img)
  if img.Repository and img.Repository ~= "<none>" then
    local tag = (img.Tag and img.Tag ~= "<none>") and img.Tag or "latest"
    return img.Repository .. ":" .. tag
  end

  return img.ID
end

local function run_image_action(action_key, images)
  if action_key == "run_interactive" then
    for _, img in ipairs(images) do
      term_cmd("docker run -it --rm " .. vim.fn.shellescape(image_ref(img)) .. " bash")
    end
  elseif action_key == "run_detached" then
    local img = images[1]

    if not img then
      return
    end

    float_input("Container name (optional):", {}, function(name)
      float_input("Ports e.g. 8080:80 (optional):", {}, function(ports)
        local args = { "docker", "run", "-d" }

        if name and name ~= "" then
          vim.list_extend(args, { "--name", name })
        end

        if ports and ports ~= "" then
          vim.list_extend(args, { "-p", ports })
        end

        table.insert(args, image_ref(img))

        exec_async(args, {
          notify = notify_opts,
          info_label = "Starting " .. image_ref(img) .. "...",
          success_label = "Container started",
          failed_label = "Failed to start container: ",
          on_success = container_mutate_success,
        })
      end)
    end)
  elseif action_key == "remove_force" then
    utils.confirm_dangerous("Force-remove " .. #images .. " image(s)?", function()
      for _, img in ipairs(images) do
        exec_async({ "docker", "rmi", "-f", img.ID }, {
          notify = notify_opts,
          info_label = "Force removing " .. image_ref(img) .. "...",
          success_label = "Removed " .. image_ref(img),
          failed_label = "Failed to remove: ",
          on_success = image_mutate_success,
        })
      end
    end)
  elseif action_key == "tag" then
    local img = images[1]

    if not img then
      return
    end

    float_input("New tag:", { default = image_ref(img) }, function(new_tag)
      if not new_tag or new_tag == "" then
        return
      end

      exec_async({ "docker", "tag", img.ID, new_tag }, {
        notify = notify_opts,
        success_label = "Tagged as " .. new_tag,
        failed_label = "Failed to tag: ",
        on_success = image_mutate_success,
      })
    end)
  elseif action_key == "inspect" then
    for _, img in ipairs(images) do
      term_cmd("docker inspect " .. vim.fn.shellescape(img.ID) .. " | less")
    end
  elseif action_key == "history" then
    for _, img in ipairs(images) do
      term_cmd("docker history " .. vim.fn.shellescape(image_ref(img)))
    end
  end
end

-- Cached image fetcher. TTL 100 s.
local get_images = cache.wrap("docker.images", 100000, function(callback)
  vim.system({ "docker", "images", "--format", "{{json .}}" }, {}, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Failed to list images: " .. (result.stderr or ""), vim.log.levels.ERROR, notify_opts)
        callback(nil)
        return
      end

      callback(parse_json_lines(result.stdout))
    end)
  end)
end)

local function image_preview(img)
  return table.concat({
    "ID:           " .. img.ID,
    "Repository:   " .. img.Repository,
    "Tag:          " .. img.Tag,
    "Size:         " .. img.Size,
    "Date:         " .. img.CreatedSince .. " (" .. img.CreatedAt .. ")",
  }, "\n")
end

open_image_picker = function()
  if not cache.is_cached("docker.images") then
    vim.notify("Loading images...", vim.log.levels.INFO, notify_opts)
  end

  local items = {}

  local function populate_items(images)
    items = {}

    for _, img in ipairs(images) do
      img.Repository = img.Repository or "N/A"
      img.Tag = img.Tag or "N/A"
      img.Size = img.Size or "N/A"

      table.insert(items, {
        text = string.format("%-25s %-9s %s", image_label(img), img.Size or "", img.CreatedSince or ""),
        ID = img.ID,
        Repository = img.Repository,
        Tag = img.Tag,
        Size = img.Size,
        CreatedSince = img.CreatedSince,
        CreatedAt = img.CreatedAt,
        preview = { text = image_preview(img), ft = "yaml" },
      })
    end
  end

  get_images(function(images)
    if not images then
      return
    end

    populate_items(images)

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        local name_col = string.format("%-25s", image_label(item))
        local size_col = string.format("%-9s", item.Size or "")
        local date_col = item.CreatedSince or ""
        return {
          { name_col, "Function" },
          { size_col, "Text" },
          { date_col, "Text" },
        }
      end,
      preview = "preview",
      layout = picker_layout({
        title = { { "  Images", "DiagnosticInfo" } },
        width_frac = 0.85,
        width_min = 100,
        height = 0.75,
        list_width = 0.4,
      }),
      multi = { "confirm" },
      actions = {
        select_and_clear = select_and_clear_action(true),
        refresh = make_refresh_action(function()
          cache.invalidate("docker.images")
        end, get_images, populate_items),
      },
      win = {
        input = {
          keys = {
            ["<Tab>"] = { "select_and_clear", mode = { "i", "n" } },
            ["<C-k>"] = { "refresh", mode = { "i", "n" }, desc = "Refresh images" },
          },
        },
      },
      confirm = function(picker)
        local selected = picker_selection(picker)
        picker:close()

        if not selected or #selected == 0 then
          return
        end

        vim.schedule(function()
          show_action_picker(selected, IMAGE_ACTIONS, run_image_action)
        end)
      end,
    })
  end)
end

function M.docker_images()
  open_image_picker()
end

-- ── Docker Build ──────────────────────────────────────────────────────────────

function M.docker_build()
  local default_tag = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

  float_input(" Image tag:", { default = default_tag }, function(tag)
    if not tag or tag == "" then
      return
    end

    float_input(" Dockerfile path:", { default = "Dockerfile" }, function(dockerfile)
      if not dockerfile or dockerfile == "" then
        return
      end

      term_cmd("docker build -t " .. vim.fn.shellescape(tag) .. " -f " .. vim.fn.shellescape(dockerfile) .. " .")
    end)
  end)
end

-- ── Docker Compose ────────────────────────────────────────────────────────────

local COMPOSE_UP_OPTIONS = {
  { text = "up (attached)", args = {} },
  { text = "up --detach", args = { "-d" } },
  { text = "up --build", args = { "--build" } },
  { text = "up --build --detach", args = { "--build", "-d" } },
}

local COMPOSE_DOWN_OPTIONS = {
  { text = "down", args = {} },
  { text = "down --volumes", args = { "--volumes" } },
  { text = "down --remove-orphans", args = { "--remove-orphans" } },
  { text = "down --volumes --remove-orphans", args = { "--volumes", "--remove-orphans" } },
}

local function show_compose_picker(title, options, on_select)
  local items = {}

  for i, opt in ipairs(options) do
    table.insert(items, { text = opt.text, _idx = i })
  end

  snacks.picker.pick({
    finder = function()
      return items
    end,
    format = "text",
    layout = picker_layout({
      title = title,
      width_frac = 0.3,
      width_min = 50,
      height = 0.25,
    }),
    confirm = function(picker, item)
      picker:close()

      if item then
        on_select(options[item._idx])
      end
    end,
  })
end

function M.docker_compose_up()
  show_compose_picker({ { "  Compose Up", "DiagnosticOk" } }, COMPOSE_UP_OPTIONS, function(opt)
    local is_detached = vim.tbl_contains(opt.args, "-d")
    local base_args = vim.list_extend({ "docker", "compose", "up" }, opt.args)

    if is_detached then
      exec_async(base_args, {
        notify = notify_opts,
        info_label = "Running docker compose up " .. table.concat(opt.args, " ") .. "...",
        success_label = "Compose up done",
        failed_label = "Compose up failed: ",
      })
    else
      term_cmd("docker compose up " .. table.concat(opt.args, " "))
    end
  end)
end

function M.docker_compose_down()
  show_compose_picker({ { "  Compose Down", "DiagnosticWarn" } }, COMPOSE_DOWN_OPTIONS, function(opt)
    local args = vim.list_extend({ "docker", "compose", "down" }, opt.args)

    exec_async(args, {
      notify = notify_opts,
      info_label = "Running docker compose down " .. table.concat(opt.args, " ") .. "...",
      success_label = "Compose down done",
      failed_label = "Compose down failed: ",
    })
  end)
end

-- Stream compose logs in a terminal tab (the missing daily companion to up/down).
function M.docker_compose_logs()
  term_cmd("docker compose logs -f --tail=100")
end

-- ── Prune / Pull ──────────────────────────────────────────────────────────────

-- Every entry deletes data, so all are gated by confirm_dangerous. `-f` skips
-- docker's own y/N because the yes-prompt already covers consent. err = wipes
-- reusable data (images/volumes), warn = clears regenerable cruft.
local PRUNE_OPTIONS = {
  { text = "dangling images", args = { "image", "prune", "-f" }, hl = HL.warn },
  { text = "all unused images", args = { "image", "prune", "-a", "-f" }, hl = HL.err },
  { text = "stopped containers", args = { "container", "prune", "-f" }, hl = HL.warn },
  { text = "unused volumes", args = { "volume", "prune", "-f" }, hl = HL.err },
  { text = "build cache", args = { "builder", "prune", "-f" }, hl = HL.warn },
  { text = "system (all unused)", args = { "system", "prune", "-f" }, hl = HL.err },
}

function M.docker_prune()
  utils.menu_picker(PRUNE_OPTIONS, function(item)
    utils.confirm_dangerous("Prune " .. item.text .. "?", function()
      -- term_cmd so the reclaimed-space report is visible.
      term_cmd("docker " .. table.concat(item.args, " "))
    end)
  end, { title = "  Prune", width_frac = 0.3, width_max = 50, height = 0.4 })
end

function M.docker_pull()
  float_input(" Image to pull (e.g. nginx:latest):", {}, function(ref)
    if not ref or ref == "" then
      return
    end
    -- Stream pull progress in a terminal; refresh the image picker with <C-k>.
    term_cmd("docker pull " .. vim.fn.shellescape(ref))
  end)
end

return M
