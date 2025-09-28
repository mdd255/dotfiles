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
  { "t", { modes = { "n", "v", "o" } } },
  { "f", { modes = { "n", "v", "o" } } },
  { "s", { modes = { "n", "v", "o" } } },
  { "<Leader>uG" },
  { "<Leader>up" },
  { "<Leader>w0" },
})

vim.cmd("nnoremap T :LualineRenameTab ")

local function comment()
  local count = vim.v.count1
  vim.cmd.normal({ args = { count .. "gcc" }, bang = false })
  vim.cmd.normal({ args = { count .. "j" }, bang = true })
end

local function add_to_dictionary()
  local spellfile = vim.fn.stdpath("config") .. "/spell/index.utf-8.add"
  local word = vim.fn.expand("<cword>")
  vim.cmd("normal! zg")
  vim.cmd("mkspell! " .. vim.fn.fnameescape(spellfile))
  print("Added '" .. word .. "' to dictionary")
end

---------------------------------------------------------------------------------------------------
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

  -- Split
  { "sn", "<cmd>split<cr>", { desc = "Split horizontally" } },
  { "se", "<cmd>vsplit<cr>", { desc = "Split vertically" } },

  -- Search nav
  { "<C-n>", "n", { modes = { "n", "x" }, desc = "Next search match" } },
  { "<C-e>", "N", { modes = { "n", "x" }, desc = "Previous search match" } },

  -- Misc
  { "V", "v$", { desc = "Visual to end of line" } },
  { "l", "%", { modes = { "n", "v" }, desc = "Goto matching pair" } },
  { "U", "<C-r>", { desc = "Redo" } },
  { "<Leader>q", "<cmd>q<Cr>", { desc = "Quit" } },
  { "<Leader>Q", "<cmd>qa!<Cr>", { desc = "Quit all" } },
  { "ss", "<cmd>w<Cr>", { desc = "Save" } },
  { "<Leader>v", "V", { desc = "Visual line mode", silent = false } },
  { "0", "^" },
  { "<C-Cr>", "<cmd>lua Snacks.terminal()<Cr>", { modes = { "t" }, desc = "Toggle terminal" } },
  { "<Leader><Tab>", "<cmd>tabnew<Cr>", { desc = "Create new tab" } },
  { "<Leader>l", "<cmd>Lazy<Cr>", { desc = "Plugins manager" } },
  { ";", comment, { desc = "Comment", remap = true } },
  { "so", add_to_dictionary, { desc = "Add current word to dictionary" } },
  { "sh", "<cmd>Inspect<Cr>", { desc = "Show current TS highlight" } },

  -- vim edit register control
  { "p", '"_dP', { modes = { "x" }, desc = "Paste without overwrite default register" } },
  { "P", '"_dP', { modes = { "x" }, desc = "Paste without overwrite default register" } },

  -- bracket mappings
  { "h", "i<", { modes = { "v", "o" }, desc = "i<" } },
  { "n", "i(", { modes = { "v", "o" }, desc = "i(" } },
  { "e", "i[", { modes = { "v", "o" }, desc = "i[" } },
  { "i", "i{", { modes = { "v", "o" }, desc = "i{" } },
  { "o", "i'", { modes = { "v", "o" }, desc = "i'" } },
  { "l", 'i"', { modes = { "v", "o" }, desc = 'i"' } },
  { "u", "i`", { modes = { "v", "o" }, desc = "i`" } },
  { "H", "a<", { modes = { "v", "o" }, desc = "a<" } },
  { "N", "a(", { modes = { "v", "o" }, desc = "a(" } },
  { "E", "a[", { modes = { "v", "o" }, desc = "a[" } },
  { "I", "a{", { modes = { "v", "o" }, desc = "a{" } },
  { "O", "a'", { modes = { "v", "o" }, desc = "a'" } },
  { "L", 'a"', { modes = { "v", "o" }, desc = 'a"' } },
  { "U", "a`", { modes = { "v", "o" }, desc = "a`" } },
})
