local hydra  = require('hydras._hydra')
local cmd    = require('hydra.keymap-util').cmd

local keymap = {
   body = '<LEADER>p',
   heads = {
      sync   = { key = 's', fn = cmd 'Lazy sync' },
      update = { key = 'u', fn = cmd 'Lazy update' },
   }
}


hydra.create({
   name   = 'Lazy',
   keymap = keymap,
   conf   = {
      position = 'middle'
   }
})
