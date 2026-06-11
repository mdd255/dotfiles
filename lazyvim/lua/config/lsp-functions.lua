local utils = require("config.utils")
local custom_layout = utils.custom_layout
local picker_selection = utils.picker_selection
local HL = utils.HL
local snacks = require("snacks")
local M = {}

local notify_opts = { title = "󰼷 LSP" }

local LSP_ACTIONS = {
  { text = " start", key = "start", hl = HL.ok },
  { text = " stop", key = "stop", hl = HL.warn },
  { text = "󰦛 restart", key = "restart", hl = HL.warn },
}

local function get_lsp_clients()
  return vim.lsp.get_clients()
end

local function client_preview(client)
  return table.concat({
    "Name:        " .. client.name,
    "ID:          " .. client.id,
    "PID:         " .. (client.pid or "N/A"),
    "Root:        " .. (client.root_dir or "N/A"),
    "Attached to: " .. vim.inspect(client.attached_buffers),
  }, "\n")
end

local function run_lsp_action(action_key, clients)
  if action_key == "start" then
    for _, client in ipairs(clients) do
      vim.notify("LSP " .. client.name .. " cannot be restarted from stopped state", vim.log.levels.WARN, notify_opts)
    end
  elseif action_key == "stop" then
    for _, client in ipairs(clients) do
      vim.lsp.stop_client(client.id, true)
      vim.notify("Stopped LSP " .. client.name, vim.log.levels.INFO, notify_opts)
    end
  elseif action_key == "restart" then
    for _, client in ipairs(clients) do
      vim.lsp.stop_client(client.id, true)
      vim.schedule(function()
        vim.cmd("e")
      end)
      vim.notify("Restarted LSP " .. client.name, vim.log.levels.INFO, notify_opts)
    end
  end
end

local function show_action_picker(selected_clients, action_list, on_action)
  utils.menu_picker(action_list, function(item)
    on_action(item.key, selected_clients)
  end, { height = 0.25 })
end

local function open_lsp_picker()
  local clients = get_lsp_clients()
  local items = {}

  if #clients == 0 then
    vim.notify("No active LSP clients", vim.log.levels.INFO, notify_opts)
    return
  end

  for _, client in ipairs(clients) do
    table.insert(items, {
      text = string.format("%-20s %s", client.name, client.root_dir or "N/A"),
      name = client.name,
      id = client.id,
      pid = client.pid,
      root_dir = client.root_dir,
      attached_buffers = client.attached_buffers,
      preview = { text = client_preview(client), ft = "yaml" },
    })
  end

  snacks.picker.pick({
    finder = function()
      return items
    end,
    format = function(item, _)
      local name_col = string.format("%-20s", item.name)

      return {
        { name_col, "Function" },
      }
    end,
    preview = "preview",
    layout = custom_layout({
      title = { { "󰼷 LSP Clients", " DiagnosticInfo" } },
      width = 0.55,
      preview_ratio = 0.7,
      preview = true,
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
      local selected = picker_selection(picker)
      picker:close()

      if not selected or #selected == 0 then
        return
      end

      vim.schedule(function()
        show_action_picker(selected, LSP_ACTIONS, run_lsp_action)
      end)
    end,
  })
end

function M.lsp_clients()
  vim.notify("Loading lsp clients ...", vim.log.levels.INFO, notify_opts)
  open_lsp_picker()
end

return M
