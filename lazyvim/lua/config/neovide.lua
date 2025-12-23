-- options
vim.o.guifont = "FiraCode Nerd Font:h11.4"
vim.g.neovide_scale_factor = 1
vim.o.title = true
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_macos_simple_fullscreen = true
vim.g.neovide_position_animation_length = 0.2
vim.g.neovide_cursor_animation_length = 0.2
vim.g.neovide_cursor_short_animation_length = 0.04
vim.g.neovide_cursor_trail_size = 0.8
vim.g.neovide_cursor_vfx_mode = "pixiedust"

-- keymaps
vim.keymap.set("t", "<A-c>", '<C-\\><C-N>"+yi')
vim.keymap.set("t", "<A-v>", '<C-\\><C-N>"+Pa')

-- auto cmds
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function()
    local cwd = vim.loop.cwd()
    local project_name = string.gsub(cwd, "^.*/", "")
    vim.o.titlestring = " " .. project_name
  end,
})
