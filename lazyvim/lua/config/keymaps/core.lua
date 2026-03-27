---@diagnostic disable: undefined-global
local utils = require("config.utils")
local map = utils.map

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

  -- Split
  { "sn", "<cmd>split<cr>", { desc = "Split horizontally" } },
  { "se", "<cmd>vsplit<cr>", { desc = "Split vertically" } },

  -- Search nav
  { "<C-n>", "n", { modes = { "n", "x" }, desc = "Next search match" } },
  { "<C-e>", "N", { modes = { "n", "x" }, desc = "Previous search match" } },

  -- Misc
  { "V", "v$", { desc = "Visual to end of line" } },
  { "_", "%", { modes = { "n", "v" }, desc = "Goto matching pair" } },
  { "U", "<C-r>", { desc = "Redo" } },
  { "<Leader>q", "<cmd>q<Cr>", { desc = "Close current window" } },
  { "<Leader>Q", "<cmd>tabclose<Cr>", { desc = "Close current tab" } },
  { "ss", "<cmd>w<Cr>", { desc = "Save" } },
  { "<Leader>v", "V", { desc = "Visual line mode", silent = false } },
  { "0", "^" },
  { "<C-Esc>", "<C-\\><C-n>", { modes = { "t" }, desc = "Exit terminal mode" } },
  { "<C-Cr>", "<cmd>lua Snacks.terminal()<Cr>", { modes = { "t" }, desc = "Toggle terminal" } },
  { "<Leader><Tab>", "<cmd>tabnew<Cr>", { desc = "Create new tab" } },
  { "<Leader>l", "<cmd>Lazy<Cr>", { desc = "Plugins manager" } },
  { "sh", "<cmd>Inspect<Cr>", { desc = "Show current TS highlight" } },
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
})

vim.cmd("nnoremap T :LualineRenameTab ")
vim.cmd("nnoremap <Cr> :")
