return {
   'stevearc/oil.nvim',
   cmd = 'Oil',
   keys = {
      { '-', function() require('oil').open_float() end }
   },
   opts = {
      watch_for_changes               = true,
      skip_confirm_for_simple_edits   = true,
      prompt_save_on_select_new_entry = false,
      view_options                    = {
         show_hidden      = false,
         case_insensitive = true,
         get_win_title    = 'File Explorer'
      },
      keymaps                         = {
         ['?']     = { 'actions.show_help', mode = 'n' },
         ['I']     = { 'actions.select', mode = 'n' },
         ['<cr>']  = { 'actions.select' },
         ['H']     = { 'actions.parent', mode = 'n' },
         ['.']     = { 'actions.toggle_hidden', mode = 'n' },
         ['q']     = { 'actions.close', mode = 'n' },
         ['<Esc>'] = { 'actions.close', mode = 'n' },
         ['R']     = { 'actions.refresh', mode = 'n' },
      },
      use_default_keymaps             = false,
      float                           = {
         max_width = 0.6,
         max_height = 0.5
      }
   },
   dependencies = { "nvim-tree/nvim-web-devicons" },
}
