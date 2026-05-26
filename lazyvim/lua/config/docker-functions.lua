local utils = require("config.utils")
local exec_async = utils.exec_async
local term_cmd = utils.term_cmd
local picker_width = utils.picker_width
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

local CONTAINER_FILTERS = {
  { name = "All", args = { "-a" } },
  { name = "Running", args = {} },
  { name = "Stopped", args = { "-a", "--filter", "status=exited" } },
}

local CONTAINER_ACTIONS = {
  { text = " exec", key = "exec_bash" },
  { text = "󰦪 view logs", key = "view_logs" },
  { text = " stats", key = "stats" },
  { text = " stop", key = "stop" },
  { text = " start", key = "start" },
  { text = " restart", key = "restart" },
  { text = "󰏤 pause", key = "pause" },
  { text = " unpause", key = "unpause" },
  { text = " remove", key = "remove" },
  { text = "✏ rename", key = "rename" },
  { text = " inspect", key = "inspect" },
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
    for _, c in ipairs(containers) do
      local args = vim.list_extend({ "docker" }, def.args)
      table.insert(args, c.ID)

      exec_async(args, {
        notify = notify_opts,
        info_label = def.verb .. " " .. c.Names .. "...",
        success_label = def.past .. " " .. c.Names,
        failed_label = "Failed to " .. action_key .. " " .. c.Names .. ": ",
        on_success = function()
          cache.invalidate_pattern("docker.containers")
          vim.schedule(open_container_picker)
        end,
      })
    end

    return
  end

  if action_key == "exec_bash" then
    for _, c in ipairs(containers) do
      term_cmd("docker exec -it " .. c.Names .. " bash")
    end
  elseif action_key == "view_logs" then
    for _, c in ipairs(containers) do
      term_cmd("docker logs -f --tail=100 " .. c.Names)
    end
  elseif action_key == "stats" then
    local names = {}

    for _, c in ipairs(containers) do
      table.insert(names, c.Names)
    end

    term_cmd("docker stats " .. table.concat(names, " "))
  elseif action_key == "inspect" then
    for _, c in ipairs(containers) do
      term_cmd("docker inspect " .. c.Names .. " | less")
    end
  elseif action_key == "rename" then
    for _, c in ipairs(containers) do
      snacks.input({ prompt = "Rename " .. c.Names .. ": ", default = c.Names }, function(new_name)
        if not new_name or new_name == "" or new_name == c.Names then
          return
        end
        exec_async({ "docker", "rename", c.Names, new_name }, {
          notify = notify_opts,
          success_label = "Renamed " .. c.Names .. " → " .. new_name,
          failed_label = "Failed to rename: ",
          on_success = function()
            cache.invalidate_pattern("docker.containers")
            vim.schedule(open_container_picker)
          end,
        })
      end)
    end
  end
end

local function show_action_picker(selected_containers, action_list, on_action)
  local items = {}

  for _, a in ipairs(action_list) do
    table.insert(items, { text = a.text, key = a.key })
  end

  snacks.picker.pick({
    finder = function()
      return items
    end,
    format = "text",
    layout = {
      layout = {
        title = { { " Action", "DiagnosticInfo" } },
        box = "vertical",
        position = "float",
        width = picker_width(0.2, 40),
        height = 0.5,
        border = "rounded",
        { win = "input", height = 1, border = "bottom" },
        { win = "list" },
      },
    },
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          on_action(item.key, selected_containers)
        end)
      end
    end,
  })
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

      local containers = {}

      for line in result.stdout:gmatch("[^\r\n]+") do
        if line ~= "" then
          local ok, data = pcall(vim.json.decode, line)

          if ok and data then
            table.insert(containers, data)
          end
        end
      end

      callback(containers)
    end)
  end)
end

-- Cached container fetcher. TTL 10 s per filter combination.
local function get_containers(filter_args, callback)
  local key = "docker.containers." .. table.concat(filter_args, "_")
  cache.wrap(key, 30000, function(cb)
    fetch_containers_raw(filter_args, cb)
  end)(callback)
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

  get_containers(f.args, function(containers)
    if not containers then
      return
    end

    local items = {}

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
      layout = {
        layout = {
          title = { { "  Containers · " .. f.name, "DiagnosticInfo" } },
          box = "vertical",
          position = "float",
          width = picker_width(0.9, 100),
          height = 0.75,
          border = "rounded",
          { win = "input", height = 1, border = "bottom" },
          {
            box = "horizontal",
            { win = "list", width = 0.45 },
            { win = "preview", border = "left" },
          },
        },
      },
      multi = { "confirm" },
      actions = {
        select_and_clear = function(picker)
          picker.list:select()
          vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, { "" })
        end,
        cycle_filter = function(picker)
          local next_idx = filter_idx % #CONTAINER_FILTERS + 1
          picker:close()
          vim.schedule(function()
            open_container_picker(next_idx)
          end)
        end,
      },
      win = {
        input = {
          keys = {
            ["<Tab>"] = { "select_and_clear", mode = { "i", "n" } },
            ["<C-o>"] = { "cycle_filter", mode = { "i", "n" }, desc = "Cycle filter" },
          },
        },
      },
      confirm = function(picker)
        local selected = picker:selected()

        if #selected == 0 then
          local item = picker:current()

          if item then
            selected = { item }
          end
        end

        picker:close()

        if #selected == 0 then
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
  { text = " run (interactive)", key = "run_interactive" },
  { text = " run (detached)", key = "run_detached" },
  { text = " remove", key = "remove_force" },
  { text = "󰓼 tag", key = "tag" },
  { text = " inspect", key = "inspect" },
  { text = "󰋚 history", key = "history" },
}

local function image_ref(img)
  if img.Repository and img.Repository ~= "<none>" then
    local tag = (img.Tag and img.Tag ~= "<none>") and img.Tag or "latest"
    local labels = vim.split(img.Repository, "/")
    return labels[#labels] .. ":" .. tag
  end

  return img.ID
end

local function run_image_action(action_key, images)
  if action_key == "run_interactive" then
    for _, img in ipairs(images) do
      term_cmd("docker run -it --rm " .. image_ref(img) .. " bash")
    end
  elseif action_key == "run_detached" then
    local img = images[1]

    if not img then
      return
    end

    snacks.input({ prompt = "Container name (optional): " }, function(name)
      snacks.input({ prompt = "Ports e.g. 8080:80 (optional): " }, function(ports)
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
          on_success = function()
            cache.invalidate_pattern("docker.containers")
            vim.schedule(open_container_picker)
          end,
        })
      end)
    end)
  elseif action_key == "remove_force" then
    for _, img in ipairs(images) do
      exec_async({ "docker", "rmi", "-f", img.ID }, {
        notify = notify_opts,
        info_label = "Force removing " .. image_ref(img) .. "...",
        success_label = "Removed " .. image_ref(img),
        failed_label = "Failed to remove: ",
        on_success = function()
          cache.invalidate("docker.images")
          vim.schedule(open_image_picker)
        end,
      })
    end
  elseif action_key == "tag" then
    local img = images[1]

    if not img then
      return
    end

    snacks.input({ prompt = "New tag: ", default = image_ref(img) }, function(new_tag)
      if not new_tag or new_tag == "" then
        return
      end

      exec_async({ "docker", "tag", img.ID, new_tag }, {
        notify = notify_opts,
        success_label = "Tagged as " .. new_tag,
        failed_label = "Failed to tag: ",
        on_success = function()
          cache.invalidate("docker.images")
          vim.schedule(open_image_picker)
        end,
      })
    end)
  elseif action_key == "inspect" then
    for _, img in ipairs(images) do
      term_cmd("docker inspect " .. img.ID .. " | less")
    end
  elseif action_key == "history" then
    for _, img in ipairs(images) do
      term_cmd("docker history " .. image_ref(img))
    end
  end
end

-- Cached image fetcher. TTL 30 s.
local get_images = cache.wrap("docker.images", 100000, function(callback)
  vim.system({ "docker", "images", "--format", "{{json .}}" }, {}, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Failed to list images: " .. (result.stderr or ""), vim.log.levels.ERROR, notify_opts)
        callback(nil)
        return
      end

      local images = {}

      for line in result.stdout:gmatch("[^\r\n]+") do
        if line ~= "" then
          local ok, data = pcall(vim.json.decode, line)
          if ok and data then
            table.insert(images, data)
          end
        end
      end
      callback(images)
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

  get_images(function(images)
    if not images then
      return
    end

    local items = {}

    for _, img in ipairs(images) do
      img.Repository = img.Repository or "N/A"
      img.Tag = img.Tag or "N/A"
      img.Size = img.Size or "N/A"

      table.insert(items, {
        text = string.format("%-25s %-9s %s", image_ref(img), img.Size or "", img.CreatedSince or ""),
        ID = img.ID,
        Repository = img.Repository,
        Tag = img.Tag,
        Size = img.Size,
        CreatedSince = img.CreatedSince,
        CreatedAt = img.CreatedAt,
        preview = { text = image_preview(img), ft = "yaml" },
      })
    end

    snacks.picker.pick({
      finder = function()
        return items
      end,
      format = function(item, _)
        local name_col = string.format("%-25s", image_ref(item))
        local size_col = string.format("%-9s", item.Size or "")
        local date_col = item.CreatedSince or ""
        return {
          { name_col, "Function" },
          { size_col, "Text" },
          { date_col, "Text" },
        }
      end,
      preview = "preview",
      layout = {
        layout = {
          title = { { "  Images", "DiagnosticInfo" } },
          box = "vertical",
          position = "float",
          width = picker_width(0.85, 100),
          height = 0.75,
          border = "rounded",
          { win = "input", height = 1, border = "bottom" },
          {
            box = "horizontal",
            { win = "list", width = 0.4 },
            { win = "preview", border = "left" },
          },
        },
      },
      multi = { "confirm" },
      actions = {
        select_and_clear = function(picker)
          picker.list:select()
          picker.list:move(1)
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

        if #selected == 0 then
          local item = picker:current()

          if item then
            selected = { item }
          end
        end

        picker:close()

        if #selected == 0 then
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

  snacks.input({ prompt = "Image tag: ", default = default_tag }, function(tag)
    if not tag or tag == "" then
      return
    end

    snacks.input({ prompt = "Dockerfile path: ", default = "Dockerfile" }, function(dockerfile)
      if not dockerfile or dockerfile == "" then
        return
      end

      term_cmd("docker build -t " .. tag .. " -f " .. dockerfile .. " .")
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
    layout = {
      layout = {
        title = title,
        box = "vertical",
        position = "float",
        width = picker_width(0.3, 50),
        height = 0.25,
        border = "rounded",
        { win = "input", height = 1, border = "bottom" },
        { win = "list" },
      },
    },
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

return M
