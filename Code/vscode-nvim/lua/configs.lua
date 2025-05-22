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
vim.o.ignorecase      = true
vim.o.smartcase       = true

-- modify vim commands
vim.api.nvim_create_autocmd('TextYankPost', {
	pattern = '*',
	callback = function()
		vim.highlight.on_yank {
			higroup = "IncSearch",
			timeout = event_delay_ms,
		}
	end,
})
