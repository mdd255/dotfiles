local utils = require('base.utils')
return {
	'folke/flash.nvim',
	opts = {
		labels = 'neioharstdqwfpluy;zxcvkm,.',
		modes = {
			char = {
				keys = {}
			}
		},
		label = {
			before = true,
			after = false,
		}
	},
	keys = {
		{
			'<C-a>',
			mode = { 'n', 'v', 'o' },
			function()
				utils.vscode_config('editor.occurrencesHighlight', 'off')
				require('flash').jump()
				utils.vscode_config('editor.occurrencesHighlight', 'singleFile')
			end,
			desc = 'Flash all'
		},
		{
			'<C-c>',
			mode = { 'n', 'x', 'o' },
			function()
				utils.vscode_config('editor.occurrencesHighlight', 'off')
				require('flash').jump({ pattern = vim.fn.expand('<cword>') })
				utils.vscode_config('editor.occurrencesHighlight', 'singleFile')
			end,
			desc = 'Flash current word'
		},
		{
			'<C-t>',
			mode = { 'n', 'x', 'o' },
			function()
				utils.vscode_config('editor.occurrencesHighlight', 'off')

				require('flash').jump({
					search = {
						max_length = 0,
					},
					pattern = "(",
					label = { after = false, before = true },
				})

				utils.vscode_config('editor.occurrencesHighlight', 'singleFile')
			end,
			desc = 'Flash open bracket'
		},
	},
}
