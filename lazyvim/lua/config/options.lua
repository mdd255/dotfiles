vim.g.maplocalleader = "t"
vim.opt.timeoutlen = 350
vim.opt.winborder = "rounded"
vim.opt.numberwidth = 1
vim.opt.swapfile = false
vim.opt.history = 200
vim.opt.undolevels = 100

-- Backup and undo configuration
vim.opt.backup = true
vim.opt.backupdir = vim.fn.stdpath("data") .. "/backup"
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undofile = true

vim.opt.mouse = ""
vim.opt.wrap = false
vim.g.diffview_active = false
vim.opt.spell = false
vim.opt.signcolumn = "yes"
vim.opt.statuscolumn = "%=%{v:relnum==0?v:lnum:v:relnum}%s"

vim.opt.fillchars = {
  diff = "",
  fold = " ",
}

vim.opt.guicursor = "n-v:block-nCursor,i-ci-ve:ver25-iCursor,c:ver25-cCursor,t:block-tCursor,r-cr-o:hor20-nCursor"
