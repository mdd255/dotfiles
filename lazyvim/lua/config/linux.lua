-- copy with alt+c, cut with alt+x, select all with alt+a, paste with alt+v
vim.keymap.set("v", "<A-c>", '"+y', { desc = "Copy" })
vim.keymap.set("v", "<A-x>", '"+d', { desc = "Cut" })
vim.keymap.set({ "n", "v" }, "<A-a>", "<Esc>ggVG", { desc = "Select all" })
vim.keymap.set({ "n", "v", "o" }, "<A-v>", '"+p', { desc = "Paste" })
vim.keymap.set({ "i", "c" }, "<A-v>", "<C-r>+", { desc = "Paste" })
vim.keymap.set("t", "<A-v>", [[<C-\><C-n>"+pi]], { desc = "Paste" })
