local utils = require("base.utils")
local map = utils.map
local action = utils.vscodeAction

vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	callback = function()
		vim.wo.relativenumber = false
		vim.cmd([[let @/='']])
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		if vim.wo.number == true then
			vim.wo.relativenumber = true
		end
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.http",
	callback = function()
		map("n", "<C-h>", action("rest-client.request"), true)
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = "untitled:Untitled-1",
	callback = function()
		map("n", "<Space>q", action("workbench.action.revertAndCloseActiveEditor"), true)
	end,
})
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.sql",
	callback = function()
		map("n", "<C-h>", action("mysql.runSQL"), true)
	end,
})
