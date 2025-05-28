_G.event_delay_ms = 100
require('base')
require('configs')
require('mappings')
require('autocmd')

local utils = require('base.utils')
local map   = utils.map

local function flash_modify(action, preserve_pos)
	preserve_pos = preserve_pos or false
	local old_pos = vim.api.nvim_win_get_cursor(0)
	local current_line = vim.api.nvim_get_current_line()
	local current_idx = vim.api.nvim_win_get_cursor(0)[2] + 1
	local current_char = current_line:sub(current_idx, current_idx)

	-- List of pair characters
	local keys = { '(', '[', '{', '<', '\'', '"', '`' }
	for _, key in pairs(keys) do
		if current_char == key then
			local _cmd = 'normal ' .. action .. current_char
			vim.cmd(_cmd)
			return
		end
	end

	-- Use flash.nvim to jump to a pair character
	require('flash').jump({
		pattern = [[[\[\]{}()<>'"`]],
		label = { after = false, before = false },
		action = function(match)
			-- match.pos is {row, col}, both 1-based
			local pos = { match.pos[1], match.pos[2] + 1 }
			vim.api.nvim_win_set_cursor(0, pos)
			local char = vim.api.nvim_get_current_line():sub(pos[2], pos[2])
			local _cmd = action .. char
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(_cmd, true, false, true), 'n', false)
			if preserve_pos then
				vim.defer_fn(function()
					vim.api.nvim_win_set_cursor(0, old_pos)
				end, 50)
			end
		end,
	})
end

map('n', 'cn', function() flash_modify('ci') end)
map('n', 'dn', function() flash_modify('di', true) end)
map('n', 'yn', function() flash_modify('yi', true) end)
map('n', 'zn', function() flash_modify('vi') end)
