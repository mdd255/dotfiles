-- neovide options
vim.g.neovide_macos_simple_fullscreen = true

-- paste with cmd+v
vim.keymap.set({ "n", "v", "o" }, "<D-v>", '"+p', { desc = "Paste" })
vim.keymap.set({ "i", "c" }, "<D-v>", "<C-r>+", { desc = "Paste" })
vim.keymap.set("t", "<D-v>", [[<C-\><C-n>"+pi]], { desc = "Paste" })
