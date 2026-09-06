---@diagnostic disable: undefined-global
local utils = require("config.utils")
local map = utils.map
local term_cmd = utils.term_cmd

-- Core navigation and editing keymaps
map({
  -- File operations
  {
    "sa",
    "<cmd>noautocmd w<cr>",
    { desc = "Save without format" },
  },

  {
    "sy",
    function()
      local filename = vim.fn.expand("%:t")
      if filename ~= nil and filename ~= "" then
        vim.fn.setreg("+", filename)
        vim.notify("Copied: " .. filename .. " to clipboard")
      else
        vim.notify("Cannot get path")
      end
    end,
    { desc = "Copy filename to clipboard" },
  },

  {
    "sY",
    function()
      local filename = vim.fn.expand("%:.")
      if filename ~= nil and filename ~= "" then
        vim.fn.setreg("+", filename)
        vim.notify("Copied: " .. filename .. " to clipboard")
      else
        vim.notify("Cannot get path")
      end
    end,
    { desc = "Copy file path to clipboard" },
  },

  -- File reload
  {
    "R",
    function()
      vim.cmd("checktime")
      vim.notify("File reloaded", vim.log.levels.INFO, { title = "Neovim" })
    end,
    { desc = "Reload current file" },
  },

  -- Comment function
  {
    ";",
    function()
      local count = vim.v.count1
      vim.cmd.normal({ args = { count .. "gcc" }, bang = false })
      vim.cmd.normal({ args = { count .. "j" }, bang = true })
    end,
    { desc = "Comment", remap = true },
  },

  -- Open Claude in new tab (cmd picked by cwd path)
  {
    "<C-o>",
    function()
      local cwd = vim.fn.getcwd():lower()
      local cmd = "claude"

      if cwd:find("/abd/", 1, true) then
        cmd = "claude-abd"
      elseif cwd:find("/accelerator-app/", 1, true) then
        cmd = "claude-app"
      end

      term_cmd(cmd)

      vim.schedule(function()
        vim.bo.filetype = "claudecode"
      end)
    end,
    { modes = { "n" }, desc = "Open Claude (auto by project path) in new tab" },
  },

  -- Window maximize
  {
    "<C-Space>",
    function()
      local is_maximized = vim.g.window_maximized or false
      if is_maximized then
        vim.cmd("wincmd =")
        vim.g.window_maximized = false
      else
        vim.cmd("resize")
        vim.cmd("vertical resize")
        vim.g.window_maximized = true
      end
    end,
    { modes = { "i", "n", "t" }, desc = "Maximize current window" },
  },
})
