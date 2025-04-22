return {
   'neoclide/coc.nvim',
   dependencies = {
      'fannheyward/telescope-coc.nvim',
   },
   -- run = ':CocInstall coc-tsserver coc-biome coc-rust-analyzer coc-json coc-deno coc-db coc-graphql coc-lua coc-snippets coc-python coc-pairs coc-go coc-sql coc-prisma coc-copilot @yaegassy/coc-tailwindcss3 coc-yaml coc-css coc-emmet coc-docker',
   build = 'npm ci',
   config = function()
      local keyset = vim.keymap.set

      -- Autocomplete
      function _G.check_back_space()
         local col = vim.fn.col('.') - 1
         return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
      end

      -- Use Tab for trigger completion with characters ahead and navigate
      local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }

      keyset(
         'i',
         '<TAB>',
         'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
         opts
      )

      keyset(
         'i',
         '<S-TAB>',
         'coc#pum#visible() ? coc#pum#prev(1) : "<S-TAB>"',
         opts
      )

      keyset(
         'i',
         '<CR>',
         [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
         opts
      )

      -- Use <c-j> to trigger snippets
      keyset(
         'i',
         '<C-SPACE>',
         '<Plug>(coc-snippets-expand-jump)'
      )

      -- Use <c-space> to trigger completion
      keyset(
         'i',
         '<C-r>',
         'coc#refresh()',
         { silent = true, expr = true }
      )

      -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
      vim.api.nvim_create_augroup('CocGroup', {})

      vim.api.nvim_create_autocmd('CursorHold', {
         group = 'CocGroup',
         command = "silent call CocActionAsync('highlight')",
      })

      -- Setup formatexpr specified filetype(s)
      vim.api.nvim_create_autocmd('FileType', {
         group = 'CocGroup',
         pattern = 'typescript,json',
         command = "setl formatexpr=CocAction('formatSelected')",
      })

      -- Update signature help on jump placeholder
      vim.api.nvim_create_autocmd('User', {
         group = 'CocGroup',
         pattern = 'CocJumpPlaceholder',
         command = "call CocActionAsync('showSignatureHelp')",
      })

      ---@diagnostic disable-next-line: redefined-local
      local opts = { silent = true, nowait = true, expr = true }
      keyset('n', '<C-d>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-d>"', opts)
      keyset('n', '<C-u>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-u>"', opts)
      keyset('i', '<C-d>', 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
      keyset('i', '<C-u>', 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
      keyset('v', '<C-d>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-u>"', opts)
      keyset('v', '<C-u>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-d>"', opts)
   end
}
