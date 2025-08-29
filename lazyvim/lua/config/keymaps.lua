-- @param lhs string
-- @param rhs any
-- @param opts? { modes: { "n", "x" }, noremap = true, silent = false, desc = "" }
-- @return nil
local function map(lhs, rhs, opts)
  opts = opts or {}
  local modes = opts.modes or { "n", "x" }
  opts.modes = nil

  if type(modes) ~= "table" then
    modes = { modes }
  end

  if opts.noremap == nil then
    opts.noremap = true
  end

  if opts.silent == nil then
    opts.silent = true
  end

  if opts.expr == nil then
    opts.expr = false
  end

  if opts.desc == nil then
    opts.desc = rhs
  end

  return vim.keymap.set(modes, lhs, rhs, opts)
end

-- @param lhs string
-- @param mode? strings
-- @return nil
local function umap(lhs, modes)
  local modes = modes or { "n", "x" }

  if type(modes) ~= "table" then
    modes = { modes }
  end

  return vim.keymap.del(modes, lhs)
end

---------------------------------------------------------------------------------------------------
-- misc
map("<cr>", ":")

-- buffer nav
map("H", "<cmd>bprevious<cr>")
map("I", "<cmd>bnext<cr>")

-- visual mode
map("<space>v", "V")
map("V", "v$")

-- search matches nav
map("<tab>", "n")
map("<s-tab>", "N")

-- scroll
map("m", "<c-d>")
map("M", "<c-u>")

-- colemak
map("n", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("e", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("i", "l")
-- insert
map("k", "i")
map("K", "I")

---------------------------------------------------------------------------------------------------
