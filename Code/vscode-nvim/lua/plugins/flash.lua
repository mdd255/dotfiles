return {
	"folke/flash.nvim",
	config = function(_, opts)
		local utils = require("base.utils")
		utils.hi("FlashLabel", { fg = utils.color.red, bg = "none" })
		utils.hi("FlashMatch", { fg = utils.color.gray, bg = "none" })
		utils.hi("FlashBackdrop", { fg = utils.color.gray, bg = "none" })
		utils.hi("FlashCurrent", { fg = utils.color.blue, bg = "none" })
		require("flash").setup(opts)
	end,
	opts = {
		labels = "neioharstdqwfpluyzxcvkmNEIOHARSTDQWFPLUYZXCVKM1234567890@#$%^&*()_+",
		modes = {
			char = {
				keys = {},
			},
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
			"<tab>",
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
			"<s-tab>",
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
			"'",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({
					pattern = [=[[([{<'"`]]=],
					search = { mode = "search" },
					label = { after = false, before = true, current = false },
				})
			end,
			desc = "Flash open bracket",
		},
		{
			"dn",
			mode = "n",
			function()
				require("flash").jump({
					pattern = [=[[([{<"'`]]=],
					search = { mode = "search" },
					label = { after = false, before = true, current = false },
					action = function(match, state)
						vim.api.nvim_win_call(match.win, function()
							vim.api.nvim_win_set_cursor(match.win, match.pos)
							local line = vim.fn.getline(".")
							local col = vim.fn.col(".")
							local char = line:sub(col, col)

							local motion_map = {
								["("] = "di)",
								["["] = "di]",
								["{"] = "di}",
								["<"] = "di>",
								['"'] = 'di"',
								["'"] = "di'",
								["`"] = "di`",
							}

							local motion = motion_map[char] or "diw"
							vim.cmd("normal! " .. motion)
						end)
					end,
				})
			end,
			desc = "Flash delete inside",
		},
		{
			"de",
			mode = "n",
			function()
				require("flash").jump({
					pattern = [=[[([{<"'`]]=],
					search = { mode = "search" },
					label = { after = false, before = true, current = false },
					action = function(match, state)
						vim.api.nvim_win_call(match.win, function()
							vim.api.nvim_win_set_cursor(match.win, match.pos)
							local line = vim.fn.getline(".")
							local col = vim.fn.col(".")
							local char = line:sub(col, col)

							local motion_map = {
								["("] = "da)",
								["["] = "da]",
								["{"] = "da}",
								["<"] = "da>",
								['"'] = 'da"',
								["'"] = "da'",
								["`"] = "da`",
							}

							local motion = motion_map[char] or "daw"
							vim.cmd("normal! " .. motion)
						end)
					end,
				})
			end,
			desc = "Flash delete around",
		},
	},
}
