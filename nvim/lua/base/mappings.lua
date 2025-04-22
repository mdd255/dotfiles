local utils = require('base.utils')
local map = utils.map
local source_conf = utils.source_conf

-- colemak keyboard layout
map('nvo', 'k', 'i')
map('nvo', 'K', 'I')
map('vo', 'W', 'w')
map('vo', 'w', 'e')

map('nv', 'n', 'j')
map('nv', 'e', 'k')
map('nv', 'i', 'l')

-- window nav
map('n', '<LEADER>i', '<C-w>l')
map('n', '<LEADER>h', '<C-w>h')
map('n', '<LEADER>e', '<C-w>k')
map('n', '<LEADER>n', '<C-w>j')

-- tabs cmds
map('n', '<LEADER>t', ':tabnew<CR>')
map('n', '<LEADER>T', ':tab split<CR>')
map('n', 'N', ':tabprev<CR>')
map('n', 'E', ':tabnext<CR>')

-- quit
map('n', '<LEADER>q', ':q<CR>')

-- undo
map('n', 'U', '<C-r>')

-- mru file nav cmds
map('n', 'I', '<C-i>')
map('n', 'H', '<C-o>')

-- terminal cmds
map('t', '<ESC>', '<C-\\><C-n>')

-- search nav cmds
map('n', '<TAB>', 'n')
map('n', '<TAB>', 'N')

-- clipboard modify
map('v', 'p', '"_dP')

-- custom select cmds
map('n', '<LEADER>v', 'V')
map('n', 'V', 'v$h')

-- toggle upper/lower/camel case
map('v', 'u', 'U')
map('v', 'l', 'u')

-- auto pairs cmds
map('i', '<C-n>', '()<LEFT>')
map('i', '<C-e>', '[]<LEFT>')
map('i', '<C-i>', '{}<ESC>i')
map('i', '<C-h>', '<><LEFT>')
map('i', '<C-;>', '``<LEFT>')
map('i', '<C-u>', '""<LEFT>')
map('i', '<C-o>', '\'\'<LEFT>')
map('i', ';v', '${}<LEFT>')

-- symbol maps
map('i', ',,', ',<CR>')

map('c', '<C-h>', '<LEFT>')
-- map('c', '<C-i>', '<RIGHT>')
map('c', '<C-e>', '<C-p>')
vim.cmd('nnoremap <CR> :')
vim.cmd('vnoremap <CR> :')
map('n', '<LEADER>s', source_conf)
