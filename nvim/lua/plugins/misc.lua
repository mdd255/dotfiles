return {
   'nvimtools/hydra.nvim', -- keymap helper
   dependencies = {
      {
         'junegunn/vim-easy-align', -- align
         keys = {
            { '<LEADER>aa', '<CMD>EasyAlign<CR>' }
         },
      },
      {
         'nacro90/numb.nvim', -- line peek
         opts = {
            show_numbers = true,
            show_cursor_line = true,
            hide_relativenumbers = true,
            number_only = false,
            centered_peeking = true
         }
      },
      {
         'chrisgrieser/nvim-recorder', -- macro
         opts =
         {
            slots    = { 'a', 'b' },
            clear    = true,
            logLevel = vim.log.levels.OFF,
            mapping  = {
               startStopRecording = 'Q',
               playMacro          = 'q',
               editMacro          = '<LEADER>cq',
            }
         }
      },
      {
         'norcalli/nvim-colorizer.lua', -- color helper
         config = function()
            require 'colorizer'.setup {
               '*'
            }
         end
      },
   }
}
