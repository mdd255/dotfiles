-- @param lhs string
-- @param rhs any
-- @param modes? string or string[]
-- @param desc? string
-- @return nil
local function map(lhs, rhs, modes, silent)
  if modes == nil then
    modes = { "n", "x" }
  end

  if type(modes) ~= "table" then
    modes = { modes }
  end

  local opts = { noremap = true, silent = silent }

  return vim.keymap.set(modes, lhs, rhs, opts)
end

-- misc
map("<cr>", ":")
map("H", "<cmd>bprevious<cr>")
map("I", "<cmd>bnext<cr>")

-- search matches nav
map("<tab>", "n")
map("<s-tab>", "N")

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

-- scroll
map("m", "<c-d>")
map("M", "<c-u>")
