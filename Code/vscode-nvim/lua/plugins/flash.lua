return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		labels = 'neioharstdqwfpluy;zxcvkm,.',
		modes = {
			char = {
				keys = {
					["f"] = "<tab>",
					["F"] = "<s-tab>"
				},
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
	},
}
