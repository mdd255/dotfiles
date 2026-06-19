---@diagnostic disable: undefined-global
local utils = require("config.utils")
local map = utils.map
local unmap = utils.unmap

local function smart_resize(grow)
  local step = 3
  local cur = vim.fn.winnr()
  local has_h = vim.fn.winnr("h") ~= cur
  local has_l = vim.fn.winnr("l") ~= cur

  if has_h or has_l then
    vim.cmd((grow and "vertical resize +" or "vertical resize -") .. step)
  else
    vim.cmd((grow and "resize +" or "resize -") .. step)
  end
end

-- Core navigation and editing keymaps
map({
  -- Jump
  { "H", "<C-o>", { desc = "Jump backward" } },
  { "I", "<C-i>", { desc = "Jump forward" } },

  -- Tab nav
  { "N", "<cmd>tabprevious<cr>", { desc = "Previous tab" } },
  { "E", "<cmd>tabnext<cr>", { desc = "Next tab" } },

  -- Scroll
  { "m", "<C-d>", { desc = "Scroll down half page" } },
  { "M", "<C-u>", { desc = "Scroll up half page" } },

  -- Window nav
  { "<Leader>h", "<C-w>h", { desc = "To left win" } },
  { "<Leader>n", "<C-w>j", { desc = "To lower win" } },
  { "<Leader>e", "<C-w>k", { desc = "To upper win" } },
  { "<Leader>i", "<C-w>l", { desc = "To right win" } },

  -- Window resize (smart: vertical resize for vsplit, horizontal for split)
  {
    "<C-h>",
    function()
      smart_resize(false)
    end,
    { desc = "Shrink window" },
  },

  {
    "<C-i>",
    function()
      smart_resize(true)
    end,
    { desc = "Expand window" },
  },

  -- Split
  { "sn", "<cmd>split<cr>", { desc = "Split horizontally" } },
  { "se", "<cmd>vsplit<cr>", { desc = "Split vertically" } },

  -- Search nav
  { "<C-n>", "n", { modes = { "n", "x" }, desc = "Next search match" } },
  { "<C-e>", "N", { modes = { "n", "x" }, desc = "Previous search match" } },

  -- Misc
  { "V", "v$", { desc = "Visual to end of line" } },
  { "go", "%", { modes = { "n", "v" }, desc = "Goto matching pair" } },
  { "U", "<C-r>", { desc = "Redo" } },
  { "<Leader>q", "<cmd>q<Cr>", { desc = "Close current window" } },
  { "ss", "<cmd>w<Cr>", { desc = "Save" } },
  { "<Leader>v", "V", { desc = "Visual line mode", silent = false } },
  { "0", "^" },
  { "<C-Esc>", "<C-\\><C-n>", { modes = { "t" }, desc = "Exit terminal mode" } },
  { "<Leader><Tab>", "<cmd>tabnew<Cr>", { desc = "Create new tab" } },
  { "<Leader>l", "<cmd>Lazy<Cr>", { desc = "Plugins manager" } },
  { "st", "<cmd>Inspect<Cr>", { desc = "Show current TS highlight" } },
  { "<Esc>", "<cmd>nohlsearch<Cr>", { desc = "Clear hlsearch", modes = { "n" } } },
  { "<S-BS>", "<C-w>", { modes = { "i" }, desc = "Delete word backward" } },

  -- vim edit register control
  { "p", '"_dP', { modes = { "x" }, desc = "Paste without overwrite default register" } },
  { "P", '"_dP', { modes = { "x" }, desc = "Paste without overwrite default register" } },

  -- fold overwrite
  { "zz", "za", { modes = { "n", "v" }, desc = "Toggle current fold" } },
  { "zn", "zj", { modes = { "n", "v" }, desc = "Goto next fold" } },
  { "ze", "zk", { modes = { "n", "v" }, desc = "Goto prev fold" } },
  { "za", "zr", { modes = { "n", "v" }, desc = "Open all folds" } },
  { "zo", "zm", { modes = { "n", "v" }, desc = "Close all folds" } },

  -- expand select
  {
    "<Tab>",
    function()
      utils.ts_expand()
    end,
    { modes = { "n", "v" }, desc = "Expand selection" },
  },
  {
    "<S-Tab>",
    function()
      utils.ts_shrink()
    end,
    { modes = { "v" }, desc = "Shrink selection" },
  },
})

unmap({
  { "j" },
  { "&" },
  { "<C-f>" },
  { "<C-b>" },
  { "<C-l>" },
})

vim.cmd("nnoremap T :LualineRenameTab ")
vim.cmd("nnoremap <Cr> :")

vim.cmd("nnoremap sh :!")
vim.cmd("nnoremap si :%s/")
