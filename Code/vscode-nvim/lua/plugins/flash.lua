return {
	"folke/flash.nvim",
	config = function(_, opts)
		local utils = require('base.utils')
		utils.hi("FlashLabel", { fg = utils.color.red, bg = "none" })
		utils.hi("FlashLabel2", { fg = utils.color.white, bg = "none" })
		utils.hi("FlashMatch", { bg = "none" })
		require('flash').setup(opts)
	end,
	opts = {
		labels = "neioharstdqwfpluy;zxcvkm",
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
			format = function(opts)
				if opts.match.label1 and opts.match.label2 then
					return {
						{ opts.match.label1, "FlashLabel" },
						{ opts.match.label2, "FlashLabel2" },
					}
				end

				return { { opts.match.label or "", "FlashLabel" } }
			end,
		},
		labeler = function(matches, state)
			local labels = state:labels()
			local label_count = #labels

			for m, match in ipairs(matches) do
				if m <= label_count then
					match.label = labels[m]
				else
					match.label1 = labels[math.floor((m - 1 - label_count) / label_count) + 1]
					match.label2 = labels[(m - 1 - label_count) % label_count + 1]
					match.label = match.label1
				end
			end
		end,
		action = function(match, state)
			if match.label1 and match.label2 then
				state:hide()
				require("flash").jump({
					search = { max_length = 0 },
					highlight = { matches = false },
					matcher = function(win)
						return vim.tbl_filter(function(m)
							return m.label1 == match.label1 and m.win == win
						end, state.results)
					end,
					labeler = function(matches)
						for _, m in ipairs(matches) do
							m.label = m.label2
							m.label1 = nil
							m.label2 = nil
						end
					end,
				})
			else
				state:jump(match)
			end
		end,
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
