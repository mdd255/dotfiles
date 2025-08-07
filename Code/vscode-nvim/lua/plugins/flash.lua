return {
	"folke/flash.nvim",
	config = function(_, opts)
		local utils = require("base.utils")
		utils.hi("FlashLabel", { fg = utils.color.blue, bg = "none" })
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
	keys = function()
		local function create_text_object_action(op, text_obj)
			return function(match, state)
				local original_win = vim.api.nvim_get_current_win()
				local original_pos = vim.api.nvim_win_get_cursor(original_win)

				vim.api.nvim_win_call(match.win, function()
					vim.api.nvim_win_set_cursor(match.win, match.pos)
					local line = vim.fn.getline(".")
					local col = vim.fn.col(".")
					local char = line:sub(col, col)

					local motion_map = {
						["("] = op .. text_obj .. ")",
						["["] = op .. text_obj .. "]",
						["{"] = op .. text_obj .. "}",
						["<"] = op .. text_obj .. ">",
						['"'] = op .. text_obj .. '"',
						["'"] = op .. text_obj .. "'",
						["`"] = op .. text_obj .. "`",
					}

					local motion = motion_map[char] or (op .. text_obj .. "w")
					vim.cmd("normal! " .. motion)

					-- For change operations, enter insert mode
					if op == "c" then
						vim.cmd("startinsert")
					end
				end)

				-- For delete/yank operations, return to original position
				if op == "d" or op == "y" then
					vim.api.nvim_set_current_win(original_win)
					vim.api.nvim_win_set_cursor(original_win, original_pos)
				end
			end
		end

		return {
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
						action = create_text_object_action("d", "i"),
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
						action = create_text_object_action("d", "a"),
					})
				end,
				desc = "Flash delete around",
			},
			{
				"cn",
				mode = "n",
				function()
					require("flash").jump({
						pattern = [=[[([{<"'`]]=],
						search = { mode = "search" },
						label = { after = false, before = true, current = false },
						action = create_text_object_action("c", "i"),
					})
				end,
				desc = "Flash change inside",
			},
			{
				"ce",
				mode = "n",
				function()
					require("flash").jump({
						pattern = [=[[([{<"'`]]=],
						search = { mode = "search" },
						label = { after = false, before = true, current = false },
						action = create_text_object_action("c", "a"),
				})
			end,
				desc = "Flash change around",
		},
			{
				"yn",
				mode = "n",
				function()
					require("flash").jump({
						pattern = [=[[([{<"'`]]=],
						search = { mode = "search" },
						label = { after = false, before = true, current = false },
						action = create_text_object_action("y", "i"),
					})
				end,
				desc = "Flash yank inside",
			},
			{
				"ye",
				mode = "n",
				function()
					require("flash").jump({
						pattern = [=[[([{<"'`]]=],
						search = { mode = "search" },
						label = { after = false, before = true, current = false },
						action = create_text_object_action("y", "a"),
					})
				end,
				desc = "Flash yank around",
			}
		}
	end,
}
