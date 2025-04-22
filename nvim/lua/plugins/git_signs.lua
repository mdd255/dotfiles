local sign = { text = '▎' }

return {
   'lewis6991/gitsigns.nvim',
   opts = {
      numhl              = false,
      linehl             = false,
      word_diff          = false,
      signcolumn         = true,
      watch_gitdir       = { interval = 1000 },
      sign_priority      = 6,
      update_debounce    = 200,
      status_formatter   = nil,
      current_line_blame = true,
      -- current_line_blame_formatter_opts = { relative_time = true },

      signs              = {
         add          = sign,
         change       = sign,
         topdelete    = sign,
         changedelete = sign,
         delete       = sign,
         untracked    = sign
      },
   },
}
