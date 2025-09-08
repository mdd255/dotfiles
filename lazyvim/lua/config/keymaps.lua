---@diagnostic disable: undefined-global
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
unmap({
  "<Leader>qq",
  "<C-h>",
  "<C-j>",
  "<C-k>",
  "<C-l>",
  "<C-Left>",
  "<C-Down>",
  "<C-Up>",
  "<C-Right>",
  "[b",
  "]b",
  "<Leader>bb",
  "<Leader>bd",
  "<Leader>`",
  "<Leader>bo",
  "<Leader>bD",
  "<Leader>ur",
  "<Leader>K",
  "<Leader>l",
  "<Leader>fn",
  "<Leader>xl",
  "<Leader>xq",
  "[q",
  "]q",
  "[e",
  "]e",
  "[w",
  "]w",
  "]w",
  "<Leader>dpp",
  "<Leader>dph",
  "<Leader>gb",
  "<Leader>gB",
  "<Leader>gy",
  "<Leader>L",
  "<Leader>ft",
  "<Leader>fT",
  "<Leader>-",
  "<Leader>|",
  "<Leader>wd",
  "<Leader>wm",
  "<Leader>uz",
  "<Leader>uZ",
  "<Leader><tab>l",
  "<Leader><tab>o",
  "<Leader><tab>f",
  "<Leader><tab>d",
  "<Leader><tab>[",
  "<Leader><tab>]",
  "<Leader><tab><tab>",
  { "<C-/>", { modes = { "n", "t" } } },
  { "<C-_>", { modes = { "n", "t" } } },
  { "<A-j>", { modes = { "n", "v", "i" } } },
  { "<A-k>", { modes = { "n", "v", "i" } } },
})

---------------------------------------------------------------------------------------------------
map({
  { "H", "<cmd>bprevious<cr>", { desc = "Previous buffer" } },
  { "I", "<cmd>bnext<cr>", { desc = "Next buffer" } },
  { "N", "<cmd>tabprevious<cr>", { desc = "Previous tab" } },
  { "E", "<cmd>tabnext<cr>", { desc = "Next tab" } },
  { "V", "v$", { desc = "Visual to end of line" } },
  { "<C-n>", "n", { modes = { "n", "x" }, desc = "Next search match" } },
  { "<C-e>", "N", { modes = { "n", "x" }, desc = "Previous search match" } },
  { "m", "<C-d>", { desc = "Scroll down half page" } },
  { "M", "<C-u>", { desc = "Scroll up half page" } },
  { "n", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down" } },
  { "e", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up" } },
  { "i", "l", { desc = "Right" } },
  { "k", "i", { desc = "Insert mode" } },
  { "K", "I", { desc = "Insert at beginning of line" } },
  { "<Leader>h", "<C-w>h", { desc = "Move to left window" } },
  { "<Leader>n", "<C-w>j", { desc = "Move to lower window" } },
  { "<Leader>e", "<C-w>k", { desc = "Move to upper window" } },
  { "<Leader>i", "<C-w>l", { desc = "Move to right window" } },
  { "sn", "<cmd>split<cr>", { desc = "Split Horizontally" } },
  { "se", "<cmd>vsplit<cr>", { desc = "Split Vertically" } },
  { "<Leader>q", "<cmd>q<cr>", { desc = "Quit" } },
  { "ss", "<cmd>w<cr>", { desc = "Save" } },
  { "<Leader>v", "V", { desc = "Visual line mode" } },
})
