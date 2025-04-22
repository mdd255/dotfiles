local hydra  = require('hydras._hydra')
local cmd    = require('hydra.keymap-util').cmd

local keymap = {
   body = '<LEADER>w',
   heads = {
      [''] = { key = 'n', fn = cmd 'resize +2', exit = false },
      [''] = { key = 'e', fn = cmd 'resize -2', exit = false },
      [''] = { key = 'h', fn = cmd 'vertical resize -2', exit = false },
      [''] = { key = 'i', fn = cmd 'vertical resize +2', exit = false },
   }
}

hydra.create({
   name   = 'Win resize',
   keymap = keymap
})
