return {
   'anuvyklack/windows.nvim',
   dependencies = {
      'anuvyklack/middleclass',
      'anuvyklack/animation.nvim'
   },
   keys         = {
      { '<C-SPACE>', '<CMD>WindowsMaximize<CR>',           mode = { 'n', 'v' } },
      { '<S-SPACE>', '<CMD>WindowsMaximizeVertically<CR>', mode = { 'n', 'v' } },
   },
   opts         =
   {
      autowidth = {
         enable   = false,
         winwidth = 1,
         filetype = {},
      },
      animation = {
         enable   = true,
         duration = 200,
         fps      = 60,
         easing   = 'in_out_sine',
      }
   }
}
