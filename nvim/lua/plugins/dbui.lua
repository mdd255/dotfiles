return {
   'kristijanhusak/vim-dadbod-ui',
   keys = {
      { '<LEADER>db', '<CMD>DBUI<CR>' }
   },
   dependencies = {
      { 'tpope/vim-dadbod',                     lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql' }, lazy = true }
   },
   config = function()
      vim.g.db_ui_force_echo_notifications   = false
      vim.g.db_ui_disable_info_notifications = true
      vim.db_ui_use_nerd_fonts               = true
      vim.db_ui_icons                        = true
      vim.db_ui_show_database_icon           = true
      vim.db_ui_disable_progress_bar         = true

      vim.api.nvim_create_autocmd(
         'FileType',
         {
            pattern = 'dbout',
            callback = function()
               vim.wo.relativenumber = false
               vim.wo.number = false
            end
         }
      )
   end
}
