local hydra = require('hydras._hydra')
local hop   = require('hop')
local cmd   = require('hydra.keymap-util').cmd

local function hint_pairs()
   return hop.hint_patterns(
      {
         current_line_only = true
      },
      '(\\|\\[\\|{\\|<\\|\'\\|"\\|`'
   )
end

local keymap = {
   body  = 's',
   heads = {
      word   = { key = 's', fn = cmd 'HopWordCurrentLine' },
      Word   = { key = 'w', fn = cmd 'HopWordMW' },
      char   = { key = 'f', fn = cmd 'HopChar1CurrentLine' },
      line   = { key = 'l', fn = cmd 'HopLineMW' },
      any    = { key = '.', fn = cmd 'HopPatternMW' },
      char2  = { key = '<space>', fn = cmd 'HopChar2MW' },
      pairs  = { key = ';', fn = hint_pairs },
      save   = { key = '<cr>', fn = cmd 'write' },
      split  = { key = 'n', fn = cmd 'split' },
      vsplit = { key = 'e', fn = cmd 'vsplit' }
   }
}

hydra.create({
   name = 'Hop',
   keymap = keymap,
   conf = { timeout = 8000 }
})
