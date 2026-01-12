---@diagnostic disable: undefined-global
local scroll_mark = require("config.scroll-mark")

-- @param lhs string|table - keymap or table of keymap configs
-- @param rhs any - command/function (ignored if lhs is table)
-- @param opts? table - options (ignored if lhs is table)
-- @return nil
-- Usage examples:
-- map("H", "<cmd>bprevious<cr>") -- single keymap with default options
-- map("H", "<cmd>bprevious<cr>", { modes = {"n"}, desc = "Previous buffer" })
-- map({
--   {"H", "<cmd>bprevious<cr>", { modes = {"n"}, desc = "Previous" }},
--   {"I", "<cmd>bnext<cr>", { modes = {"n", "v"}, silent = false }},
--   {"<cr>", ":", { modes = {"n"} }}
-- })
local function map(lhs, rhs, opts)
  local default_opts = opts or {}

  for _, item in ipairs(lhs) do
    if type(item) == "table" and #item >= 2 then
      -- Table format: {keymap, command, opts}
      local key = item[1]
      local command = item[2]
      local key_opts = vim.tbl_deep_extend("force", {}, default_opts, item[3] or {})

      local modes = key_opts.modes or { "n", "x" }
      key_opts.modes = nil

      if type(modes) ~= "table" then
        modes = { modes }
      end

      if key_opts.noremap == nil then
        key_opts.noremap = true
      end

      if key_opts.silent == nil then
        key_opts.silent = true
      end

      if key_opts.expr == nil then
        key_opts.expr = false
      end

      if key_opts.desc == nil then
        key_opts.desc = command
      end

      vim.keymap.set(modes, key, command, key_opts)
    end
  end
end

-- @param lhs string|table - keymap or table of keymaps/configs
-- @param modes? string|table - default modes if lhs is string, or fallback modes
-- @return nil
-- Usage examples:
-- unmap("H") -- unmap "H" in normal mode
-- unmap("H", {"n", "v"}) -- unmap "H" in normal and visual modes
-- unmap({"H", "I", "m"}) -- unmap multiple keys in normal mode
-- unmap({{"H", {"n", "v"}}, {"I", "n"}, "m"}) -- mixed: H in n+v, I in n, m in default
local function unmap(lhs, modes)
  local default_modes = modes or { "n" }

  if type(default_modes) ~= "table" then
    default_modes = { default_modes }
  end

  for _, item in ipairs(lhs) do
    if type(item) == "string" then
      -- Simple string keymap, use default modes
      pcall(vim.keymap.del, default_modes, item)
    elseif type(item) == "table" and #item >= 1 then
      -- Table format: {keymap, modes}
      local key = item[1]
      local key_modes = item[2] or default_modes

      if type(key_modes) ~= "table" then
        key_modes = { key_modes }
      end

      pcall(vim.keymap.del, key_modes, key)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Disable LazyVim default keymaps
unmap({
  -- Misc
  { "<Leader>up" },
  { "<Leader>w0" },
  { "gO" },
  -- LSP
  { "gra" },
  { "gri" },
  { "grn" },
  { "grr" },
  { "grt" },
})

vim.cmd("nnoremap T :LualineRenameTab ")
vim.cmd("nnoremap <Cr> :")

local function comment()
  local count = vim.v.count1
  vim.cmd.normal({ args = { count .. "gcc" }, bang = false })
  vim.cmd.normal({ args = { count .. "j" }, bang = true })
end

local is_maximized = false

local function toggle_maximize()
  if is_maximized then
    vim.cmd("wincmd =")
    is_maximized = false
  else
    vim.cmd("resize")
    vim.cmd("vertical resize")
    is_maximized = true
  end
end

local function copy_filename(include_path)
  local filename = vim.fn.expand("%:t")

  if include_path == true then
    filename = vim.fn.expand("%:.")
  end

  if filename ~= nil and #filename >= 4 then
    vim.fn.setreg("+", filename)
    vim.notify("Copied: " .. filename .. " to clipboard")
  else
    vim.notify("Cannot get path")
  end
end

map({
  -- Jump
  { "H", "<C-o>", { desc = "Jump backward" } },
  { "I", "<C-i>", { desc = "Jump forward" } },

  -- Tab nav
  { "N", "<cmd>tabprevious<cr>", { desc = "Previous tab" } },
  { "E", "<cmd>tabnext<cr>", { desc = "Next tab" } },

  -- Scroll
  { "m", scroll_mark.scroll_down, { desc = "Scroll down half page" } },
  { "M", scroll_mark.scroll_up, { desc = "Scroll up half page" } },

  -- Colemak
  { "n", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down" } },
  { "e", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up" } },
  { "i", "l", { desc = "Right" } },
  { "k", "i", { desc = "Insert mode" } },
  { "K", "I", { desc = "Insert at beginning of line" } },

  -- Window nav
  { "<Leader>h", "<C-w>h", { desc = "To left win" } },
  { "<Leader>n", "<C-w>j", { desc = "To lower win" } },
  { "<Leader>e", "<C-w>k", { desc = "To upper win" } },
  { "<Leader>i", "<C-w>l", { desc = "To right win" } },
  { "<C-Space>", toggle_maximize, { modes = { "i", "n", "t" }, desc = "Maximize current window" } },

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
  { "<C-Cr>", "<cmd>lua Snacks.terminal()<Cr>", { modes = { "t" }, desc = "Toggle terminal" } },
  { "<Leader><Tab>", "<cmd>tabnew<Cr>", { desc = "Create new tab" } },
  { "<Leader>l", "<cmd>Lazy<Cr>", { desc = "Plugins manager" } },
  { ";", comment, { desc = "Comment", remap = true } },
  { "sh", "<cmd>Inspect<Cr>", { desc = "Show current TS highlight" } },
  { "sy", copy_filename, { desc = "Copy filename to clipboard" } },
  { "<Esc>", "<cmd>nohlsearch<Cr>", { desc = "Clear hlsearch", modes = { "n" } } },
  { "<S-BS>", "<C-w>", { modes = { "i" }, desc = "Delete word backward" } },
  {
    "R",
    function()
      vim.cmd("checktime")
      vim.notify("File reloaded", vim.log.levels.INFO, { title = "Neovim" })
    end,
    { desc = "Reload current file" },
  },
  {
    "sY",
    function()
      copy_filename(true)
    end,
    { desc = "Copy file path to clipboard" },
  },

  -- vim edit register control
  { "p", '"_dP', { modes = { "x" }, desc = "Paste without overwrite default register" } },
  { "P", '"_dP', { modes = { "x" }, desc = "Paste without overwrite default register" } },

  -- bracket mappings
  { "ah", "i<", { modes = { "o", "v" }, desc = "i<" } },
  { "an", "i(", { modes = { "o", "v" }, desc = "i(" } },
  { "ae", "i[", { modes = { "o", "v" }, desc = "i[" } },
  { "ai", "i{", { modes = { "o", "v" }, desc = "i{" } },
  { "ao", "i'", { modes = { "o", "v" }, desc = "i'" } },
  { "al", 'i"', { modes = { "o", "v" }, desc = 'i"' } },
  { "au", "i`", { modes = { "o", "v" }, desc = "i`" } },
  { "rh", "a<", { modes = { "o", "v" }, desc = "a<" } },
  { "rn", "a(", { modes = { "o", "v" }, desc = "a(" } },
  { "re", "a[", { modes = { "o", "v" }, desc = "a[" } },
  { "ri", "a{", { modes = { "o", "v" }, desc = "a{" } },
  { "ro", "a'", { modes = { "o", "v" }, desc = "a'" } },
  { "rl", 'a"', { modes = { "o", "v" }, desc = 'a"' } },
  { "ru", "a`", { modes = { "o", "v" }, desc = "a`" } },

  -- fold overwrite
  { "zz", "za", { modes = { "n", "v" }, desc = "Toggle current fold" } },
  { "zn", "zj", { modes = { "n", "v" }, desc = "Goto next fold" } },
  { "ze", "zk", { modes = { "n", "v" }, desc = "Goto prev fold" } },
  { "za", "zr", { modes = { "n", "v" }, desc = "Open all folds" } },
  { "zo", "zm", { modes = { "n", "v" }, desc = "Close all folds" } },
})
