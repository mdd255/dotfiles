return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		labels = 'neioharstdqwfpluy;zxcvkm,.',
		modes = {
			char = {
				keys = { "," },
			}
		}
	},
	-- stylua: ignore
	keys = {
		{
			"<C-a>",
			mode = { "n" },
			function() require("flash").jump({}) end,
			desc = "Flash all"
		},
		{
			"<C-c>",
			mode = { "n", "x", "o" },
			function() require("flash").jump({ pattern = vim.fn.expand("<cword>") }) end,
			desc = "Flash current word"
		},
		{
			"<C-t>",
			mode = { "n", "x", "o" },
			function() require("flash").treesitter() end,
			desc = "Flash Treesitter"
		},
	},
}
