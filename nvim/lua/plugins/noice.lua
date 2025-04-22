local color = require('base.utils').color

return {
   'folke/noice.nvim',
   dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
   },
   config = function()
      local notify = require('notify')

      notify.setup({
         background_colour = color.black
      })

      vim.notify = notify

      require('noice').setup({
         lsp = {
            override = {
               ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
               ['vim.lsp.util.stylize_markdown'] = true,
            },
         },
         presets = {
            bottom_search = true,         -- use a classic bottom cmdline for search
            command_palette = false,      -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = true,            -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = true,        -- add a border to hover docs and signature help
         },
         routes = {
            {
               filter = {
                  event = 'msg_show',
                  kind = '',
                  find = 'written',
               },
               opts = { skip = true },
            },
         },
         views = {
            cmdline_popup = {
               position = {
                  row = 22,
                  col = '50%',
               },
               size = {
                  width = 60,
                  height = 'auto',
               },
            },
            popupmenu = {
               relative = 'editor',
               position = {
                  row = 25,
                  col = '50%',
               },
               size = {
                  width = 60,
                  height = 10,
               },
               border = {
                  style = 'rounded',
                  padding = { 0, 1 },
               },
               win_options = {
                  winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
               },
            },
         },
      })
   end
}
