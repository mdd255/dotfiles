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
    opts.silent = false
  end

  if opts.desc == nil then
    opts.desc = rhs
  end

  return vim.keymap.set(modes, lhs, rhs, opts)
end

map("<space><tab>q", "<cmd>tabclose<cr>", { modes = "n" })
-- misc
map("<cr>", ":")

-- buffer nav
map("H", "<cmd>bprevious<cr>")
map("I", "<cmd>bnext<cr>")

-- tabs
map("<space><tab>q", "<cmd>tabclose<cr>", { modes = "n" })

-- visual mode
map("<space>v", "V", { desc = "visual line" })
map("V", "v$")

-- search matches nav
map("<tab>", "n")
map("<s-tab>", "N")

-- scroll
map("m", "<c-d>")
map("M", "<c-u>")

-- colemak
map("n", "j")
map("e", "k")
map("i", "l")
map("k", "i")
map("K", "I")

-- marks
for i = 97, 122 do
  local key = string.char(i)
  map("l" .. key, "m" .. key)
end

for i = 1, 9 do
  local key = tostring(i)
  map("l" .. key, "m" .. key)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function del_map(lhs, modes)
  if modes == nil then
    modes = { "n" }
  end

  vim.keymap.del(modes, lhs)
end

-- tabs
del_map("<space><tab>l")
del_map("<space><tab>o")
del_map("<space><tab>f")
del_map("<space><tab>[")
del_map("<space><tab>]")
del_map("<space><tab>d")

-- windows
del_map("<space>wd")
del_map("<space>|")
del_map("<space>-")

-- misc
del_map("<space>E")
del_map("<space>K")
del_map("<space>K")

-- search
del_map("<space>sG")
del_map("<space>sj")
del_map("<space>sW")
del_map("<space>sB")
del_map("<space>sC")
del_map("<space>sT")
del_map("<space>su")

-- find
del_map("<space>fE")
del_map("<space>fF")
del_map("<space>fT")
