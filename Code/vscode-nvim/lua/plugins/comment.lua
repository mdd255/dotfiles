return {
   'numToStr/Comment.nvim',
   dependencies = {
      'folke/todo-comments.nvim'
   },
   config = function()
      local keycodes = {
         line   = '<c-;>',
         vline  = '<c-;>',
         block  = '*',
         vblock = '*',
      }

      local comment = require('Comment')
      local ft = require('Comment.ft')

      comment.setup({
         padding   = true,
         sticky    = true,
         ignore    = nil,
         toggler   = {
            line  = keycodes.line,
            block = keycodes.block,
         },
         opleader  = {
            line  = keycodes.vline,
            block = keycodes.vblock,
         },
         mappings  = {
            basic = true,
            extra = false
         },
         post_hook = function(ctx)
            if ctx.range.srow == ctx.range.erow then
               vim.cmd('normal! j')
            end
         end
      })

      ft.set('env', '#%s')
      ft.set('http', '#%s')
   end
}
