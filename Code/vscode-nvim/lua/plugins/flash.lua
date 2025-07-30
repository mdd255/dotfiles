return {
	"folke/flash.nvim",
	config = function(_, opts)
		local utils = require('base.utils')
		utils.hi("FlashLabel", { fg = utils.color.red, bg = "none" })
		require('flash').setup(opts)
	end,
	opts = {
		labels = "neioharstdqwfpluy;zxcvkm-",
		modes = {
			char = {
				keys = {}
			}
		},
		label = {
			uppercase = false,
			current = false,
			before = true,
			after = false,
		},
	},
	keys = {
		{
			"W",
			mode = { "n", "v", "o" },
			function()
				require("flash").jump({
					multi_windows = false,
					search = { mode = "search", max_length = 0 },
					pattern = [[\<]],
				})
			end,
			desc = "Flash to beginning of word",
		},
		{
			"B",
			mode = { "n", "v", "o" },
			function()
				require("flash").jump({
					multi_windows = false,
					search = { mode = "search", max_length = 0 },
					pattern = [[\>]],
				})
			end,
			desc = "Flash to end of word",
		},
		{
			"<C-t>",
			mode = { "n", "v", "o" },
			function()
				require("flash").jump({ multi_windows = false })
			end,
			desc = "Flash to any",
		},
		{
			"<C-c>",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({ pattern = vim.fn.expand("<cword>") })
			end,
			desc = "Flash current word",
		},
		{
			"'",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({
					pattern = [=[[\[({<]\+]=],
					search = { mode = "search" },
					label = { after = false, before = true },
				})
			end,
			desc = "Flash open bracket/quote",
		},
	},
}
