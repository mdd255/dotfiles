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
				if vscode then
					vscode.update_config('editor.occurrencesHighlight', 'off', 'global')
				end

				require('flash').jump()

				if vscode then
					vscode.update_config('editor.occurrencesHighlight', 'singleFile', 'global')
				end
			end,
			desc = 'Flash all'
		},
		{
			'<C-c>',
			mode = { 'n', 'x', 'o' },
			function()
				if vscode then
					vscode.update_config('editor.occurrencesHighlight', 'off', 'global')
				end

				require('flash').jump({ pattern = vim.fn.expand('<cword>') })

				if vscode then
					vscode.update_config('editor.occurrencesHighlight', 'singleFile', 'global')
				end
			end,
			desc = 'Flash current word'
		},
		{
			'<C-t>',
			mode = { 'n', 'x', 'o' },
			function()
				if vscode then
					vscode.update_config('editor.occurrencesHighlight', 'off', 'global')
				end

				require('flash').jump({
					search = {
						max_length = 0,
					},
					pattern = "(",
					label = { after = false, before = true },
				})

				if vscode then
					vscode.update_config('editor.occurrencesHighlight', 'singleFile', 'global')
				end
			end,
			desc = 'Flash open bracket'
		},
		{
			'<tab>',
			mode = { 'n', 'x', 'o' },
			function()
				if vscode then
					vscode.update_config('editor.occurrencesHighlight', 'off', 'global')
				end

				require('flash').jump({
					search = {
						mode = 'search',
						max_length = 2,
					},
				})

				if vscode then
					vscode.update_config('editor.occurrencesHighlight', 'singleFile', 'global')
				end
			end,
			desc = 'Flash pair'
		},
	},
}
