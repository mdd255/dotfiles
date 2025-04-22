return {
   'kevinhwang91/nvim-ufo',
   dependencies = {
      'kevinhwang91/promise-async',
      'anuvyklack/pretty-fold.nvim',
   },
   keys = {
      { 'zA', function() require('ufo').openAllFolds() end },
      { 'zF', function() require('ufo').closeAllFolds() end },
   },
   config = function()
      local ufo = require('ufo')

      ufo.setup({
         provider_selector = function(_, _, _)
            return { 'treesitter', 'indent' }
         end
      })

      vim.cmd('hi default link UfoPreviewSbar PmenuSbar')
      vim.cmd('hi default link UfoPreviewThumb PmenuThumb')
      vim.cmd('hi default link UfoPreviewWinBar UfoFoldedBg')
      vim.cmd('hi default link UfoPreviewCursorLine Visual')
      vim.cmd('hi default link UfoFoldedEllipsis Comment')
      vim.cmd('hi UfoFoldedBg guibg=None')
      vim.cmd('hi clear Folded')
   end
}
