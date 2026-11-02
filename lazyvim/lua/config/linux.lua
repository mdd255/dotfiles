-- paste with alt+v
vim.keymap.set({ "n", "v", "o" }, "<A-v>", '"+p', { desc = "Paste" })
vim.keymap.set({ "i", "c" }, "<A-v>", "<C-r>+", { desc = "Paste" })
vim.keymap.set("t", "<A-v>", [[<C-\><C-n>"+pi]], { desc = "Paste" })
