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
  { "p", "P", { modes = { "x" }, desc = "Paste without overwrite default register" } },

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

-- si: substitute form. Find defaults to word under cursor (visual: single-line selection); find +
-- replace complete from words of the current buffer, and matches of find highlight live
-- (same case rules as :s, limited to the selected lines in visual). Visual: replace limited to selected lines.
local WORDS_MAX_LINES = 20000
local WORDS_MAX = 500

local function buffer_words(buf)
  local counts, order = {}, {}
  local lines = vim.api.nvim_buf_get_lines(buf, 0, math.min(WORDS_MAX_LINES, vim.api.nvim_buf_line_count(buf)), false)

  for _, line in ipairs(lines) do
    for w in line:gmatch("[%w_]+") do
      if #w >= 2 then
        if not counts[w] then
          counts[w] = 0
          table.insert(order, w)
        end

        counts[w] = counts[w] + 1
      end
    end
  end

  table.sort(order, function(a, b)
    return counts[a] > counts[b]
  end)

  return vim.list_slice(order, 1, WORDS_MAX)
end

-- highlight pattern matching what :s would match (case flags, line range)
local function highlight_pattern(find, flags, first, last)
  local case = ""

  if flags:find("I", 1, true) then
    case = "\\C"
  elseif vim.o.ignorecase then
    local has_upper = find:gsub("\\.", ""):find("%u") ~= nil
    case = (vim.o.smartcase and has_upper) and "\\C" or "\\c"
  end

  if first then
    return string.format("%s\\%%>%dl\\%%<%dl\\%%(%s\\)", case, first - 1, last + 1, find)
  end

  return case .. find
end

local function substitute_form(visual)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local find = vim.fn.expand("<cword>")
  local range = "%"
  local first, last

  if visual then
    local mode = vim.fn.mode()
    local s, e = vim.fn.line("v"), vim.fn.line(".")
    local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })

    first, last = math.min(s, e), math.max(s, e)
    range = first .. "," .. last
    find = #region == 1 and vim.fn.escape(region[1], [[\/.*$^~[]]) or ""
    vim.cmd("normal! \27")
  end

  local words = buffer_words(buf)
  local hl_id

  local function clear_hl()
    if hl_id then
      pcall(vim.fn.matchdelete, hl_id, win)
      hl_id = nil
    end
  end

  utils.form({
    title = " \u{f002} Substitute ",
    submit_label = "replace",
    fields = {
      { key = "find", icon = "\u{f002}", label = "Find", value = find, hint = "pattern", required = true, items = words },
      { key = "replace", icon = "\u{f021}", label = "Replace", value = "", hint = "replacement", items = words },
      { key = "flags", icon = "\u{f024}", label = "Flags", value = "g", hint = "g gc gI gcI", items = { "g", "gc", "gI", "gcI" } },
    },
    on_change = function(d)
      clear_hl()

      if d.find ~= "" and vim.api.nvim_win_is_valid(win) then
        local pat = highlight_pattern(d.find, d.flags, first, last)
        local ok, id = pcall(vim.fn.matchadd, "IncSearch", pat, 10, -1, { window = win })
        hl_id = ok and id or nil
      end

      vim.cmd("redraw")
    end,
    on_close = clear_hl,
    on_submit = function(d)
      -- escape the "/" delimiter, but keep already escaped pairs (\/, \\) as typed
      local function esc(s)
        local out, i = {}, 1

        while i <= #s do
          local c = s:sub(i, i)

          if c == "\\" then
            table.insert(out, s:sub(i, i + 1))
            i = i + 2
          else
            table.insert(out, c == "/" and "\\/" or c)
            i = i + 1
          end
        end

        return table.concat(out)
      end

      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
      end

      local ok, err = pcall(vim.cmd, string.format("%ss/%s/%s/%s", range, esc(d.find), esc(d.replace), d.flags))

      if not ok then
        vim.notify(tostring(err), vim.log.levels.ERROR, { title = "Substitute" })
      end
    end,
  })
end

map({
  {
    "si",
    function()
      substitute_form(vim.fn.mode():match("[vV\22]") ~= nil)
    end,
    { modes = { "n", "x" }, desc = "Substitute form" },
  },
})
