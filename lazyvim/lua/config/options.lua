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

-- Create backup and undo directories if they don't exist
local function ensure_dir_exists(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then
    vim.loop.fs_mkdir(path, 448)
  end
end

ensure_dir_exists(vim.fn.stdpath("data") .. "/backup")
ensure_dir_exists(vim.fn.stdpath("data") .. "/undo")

-- Performance monitoring
vim.defer_fn(function()
  local start_time = vim.loop.hrtime()

  vim.defer_fn(function()
    local elapsed = (vim.loop.hrtime() - start_time) / 1e6

    if elapsed > 100 then
      vim.notify("Startup: " .. math.floor(elapsed) .. "ms", vim.log.levels.INFO)
    end
  end, 100)
end, 100)

vim.opt.mouse = ""
vim.opt.wrap = false
vim.g.diffview_active = false
vim.opt.spell = false
vim.opt.scroll = 25
vim.opt.signcolumn = "yes"
vim.opt.statuscolumn = "%=%{v:relnum==0?v:lnum:v:relnum}%s"

vim.opt.fillchars = {
  diff = "",
  fold = " ",
}
