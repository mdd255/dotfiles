local utils = require('base.utils')
return {
	'folke/flash.nvim',
	opts = {
		labels = 'neioharstdqwfpluy;zxcvkm',
		modes = {
			char = {
				keys = {}
			}
		},
		label = {
			uppercase = false,
			current = true,
			before = true,
			after = false,
		}
	},
	keys = {
		{
			'W',
			mode = { 'n', 'v', 'o' },
			function()
				require('flash').jump({
					multi_windows = false,
					search = { mode = "search", max_length = 0 },
					pattern = [[\<]],
				})
			end,
			desc = 'Flash to beginning of word'
		},
		{
			'B',
			mode = { 'n', 'v', 'o' },
			function()
				require('flash').jump({
					multi_windows = false,
					search = { mode = "search", max_length = 0 },
					pattern = [[\>]],
				})
			end,
			desc = 'Flash to end of word'
		},
		{
			"'",
			mode = { 'n', 'v', 'o' },
			function()
				require('flash').jump({ multi_windows = false })
			end,
			desc = 'Flash to any'
		},
		{
			'<C-c>',
			mode = { 'n', 'x', 'o' },
			function()
				require('flash').jump({ pattern = vim.fn.expand('<cword>') })
			end,
			desc = 'Flash current word'
		},
		{
			'<C-t>',
			mode = { 'n', 'x', 'o' },
			function()
				require('flash').jump({
					pattern = "[(\\[{<]", -- matches all open brackets: (, [, {, <
					label = { after = false, before = true },
				})
			end,
			desc = 'Flash open bracket'
		},
	},
}
