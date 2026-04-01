-- When loaded via -u flag, runtimepath doesn't include this config dir
vim.opt.runtimepath:prepend(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h"))

_G.event_delay_ms = 100
require("base")
require("configs")
require("mappings")
require("autocmd")
