local utils           = require('base.utils')
local hi              = utils.hi
local higroup         = utils.higroup
local color           = utils.color
local map             = utils.map
local post_paste      = utils.post_paste
local pre_highlight   = utils.pre_highlight

-- configurations
vim.o.termguicolors   = true
vim.o.backup          = false
vim.o.writebackup     = false
vim.o.clipboard       = 'unnamedplus'
vim.o.undodir         = os.getenv('HOME') .. '/.nvim/undodir'
vim.o.undofile        = true
vim.o.history         = 100
vim.wo.number         = true
vim.wo.relativenumber = true

-- highlight groups
hi(higroup.change_pre, { bg = color.yellow })
hi(higroup.del_pre, { bg = color.red })
hi(higroup.yank_pre, { bg = color.blue })
hi(higroup.paste_post, { bg = color.green })
hi(higroup.hop_next_key, { fg = color.red })
hi(higroup.hop_next_key1, { fg = color.red })
hi(higroup.hop_next_key2, { fg = color.blue })

-- modify vim commands
vim.api.nvim_create_autocmd('TextYankPost', {
	pattern = '*',
	callback = function()
		vim.highlight.on_yank {
			higroup = higroup.yank_pre,
			timeout = event_delay_ms,
		}
	end,
})

map('n', 'dd', function() pre_highlight('dd', higroup.del_pre) end)
map('n', 'cc', function() pre_highlight('cc', higroup.change_pre, 'startinsert') end)
map('n', 'p', post_paste)
