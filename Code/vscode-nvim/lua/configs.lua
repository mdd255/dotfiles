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
-- hi(higroup.change_pre, { bg = color.yellow })
-- hi(higroup.del_pre, { bg = color.red })
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

local function pre_d_hl(selection_cmd)
	return pre_highlight(selection_cmd, color.red, 'd')
end

local function pre_c_hl(selection_cmd)
	return pre_highlight(selection_cmd, color.yellow, 'c')
end

map('n', 'dd', function() pre_d_hl('V') end)
map('n', 'D', function() pre_d_hl('v$h') end)

map('n', 'cc', function() pre_c_hl('V') end)
map('n', 'C', function() pre_c_hl('v$h') end)
map('n', 'p', post_paste)
map('n', 'P', function() post_paste(true) end)
