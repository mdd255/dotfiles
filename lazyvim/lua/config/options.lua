vim.g.maplocalleader = "t"
vim.opt.timeoutlen = 500
vim.opt.winborder = "rounded"
vim.opt.numberwidth = 4
vim.opt.swapfile = false
vim.opt.history = 200
vim.opt.undolevels = 100
vim.opt.mouse = ""
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/index.utf-8.add"

if vim.g.neovide then
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_fullscreen = true
  vim.g.neovide_position_animation_length = 0.2
  vim.g.neovide_cursor_animation_length = 0.2
  vim.g.neovide_cursor_short_animation_length = 0.05
  vim.g.neovide_cursor_trail_size = 0.5
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
end
