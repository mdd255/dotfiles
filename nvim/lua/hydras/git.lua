local hydra = require('hydras._hydra')
local cmd   = require('hydra.keymap-util').cmd
local git   = require('gitsigns')


local function toggle_zen_mode()
   git.toggle_linehl()
   git.toggle_deleted()
end

local keymap = {
   body  = 'g',
   heads = {
      ['Next hunk']         = { key = 'n', fn = git.next_hunk, exit = false },
      ['Prev hunk']         = { key = 'e', fn = git.prev_hunk, exit = false },
      ['Reset hunk']        = { key = 'u', fn = git.reset_hunk, exit = false },
      ['Reset all hunks']   = { key = 'U', fn = git.reset_buffer },
      ['Stage hunk']        = { key = 's', fn = git.stage_hunk, exit = false },
      ['Stage all hunks']   = { key = 'S', fn = git.stage_buffer },
      ['Toggle zen mode']   = { key = '>', fn = toggle_zen_mode, exit = false },
      ['Preview hunk']      = { key = '.', fn = git.preview_hunk_inline, exit = false },
      ['Open diffview']     = { key = '<cr>', fn = cmd 'DiffviewOpen' },
      ['Open file history'] = { key = '<tab>', fn = cmd 'DiffviewFileHistory' },
      gg                    = { key = 'g', fn = cmd 'normal! gg' },
      gh                    = { key = 'h', fn = cmd 'normal! ^' },
      gi                    = { key = 'i', fn = cmd 'normal! $' },
   }
}

hydra.create({
   name = 'Git',
   keymap = keymap,
   conf = {
      wait = true,
      timeout = 8000,
      on_exit = function()
         git.toggle_linehl(false)
         git.toggle_deleted(false)
      end
   }
})
