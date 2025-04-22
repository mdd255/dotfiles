local map                      = require('base.utils').map

local small_layout             = {
   width           = 0.35,
   height          = 0.35,
   preview_width   = 0,
   prompt_position = 'top'
}

local medium_layout            = {
   width         = 0.6,
   height        = 0.5,
   preview_width = 0,
}

local zoom_layout              = {
   width         = 0.999,
   height        = 0.6,
   preview_width = 0
}

local zoom_layout_with_preview = {
   width         = 0.999,
   height        = 0.6,
   preview_width = 0.5
}

return {
   'nvim-telescope/telescope.nvim',
   keys = {
      { '<SPACE><SPACE>', require('telescope.builtin').command_history },
      { '/',              require('telescope.builtin').current_buffer_fuzzy_find },
   },
   cmd = 'Telescope',
   dependencies = {
      'nvim-telescope/telescope-project.nvim',
      'Snikimonkd/telescope-git-conflicts.nvim',
      'nvim-telescope/telescope-github.nvim',
      {
         'nvim-telescope/telescope-fzf-native.nvim',
         build = 'make'
      },
   },
   config = function()
      local actions    = require('telescope.actions')
      local previewers = require('telescope.previewers')
      local telescope  = require('telescope')
      local sorters    = require('telescope.sorters')

      if pcall(require, 'plenary') then
         RELOAD = require('plenary.reload').reload_module

         R = function(name)
            RELOAD(name)
            return require(name)
         end
      end

      local insert_mappings = {
         i = {
            ['<ESC>'] = actions.close,
         }
      }

      telescope.setup {
         defaults = {
            find_command           = {
               'ag', '--silent', '--nocolor', '--follow', '--literal', '-g', '',
               '--ignore', '.gitignore',
               '--hidden', '--no-heading',
               '--line-number', '--column', '--smart-case'
            },
            file_ignore_patterns   = {
               '.git/', 'node_modules/', '.package-lock.json', '.pnpm-lock.yaml', '.yarn-lock.json',
               'dist/', 'debug-adapters/', '.next/', '.cache/', '.cargo/', '.gnupg/', '.oh-my-zsh/plugins/',
               'target', '@generated'
            },
            prompt_prefix          = '   ',
            selection_caret        = '-> ',
            entry_prefix           = '   ',
            initial_mode           = 'insert',
            selection_strategy     = 'reset',
            sorting_strategy       = 'ascending',
            layout_strategy        = 'horizontal',
            file_sorter            = sorters.get_fuzzy_file,
            generic_sorter         = sorters.get_generic_fuzzy_sorter,
            path_display           = { 'filename_first' },
            winblend               = 0,
            border                 = {},
            borderchars            = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
            color_devicons         = true,
            use_less               = true,
            set_env                = { ['COLORTERM'] = 'truecolor' },
            file_previewer         = previewers.vim_buffer_cat.new,
            grep_previewer         = previewers.vim_buffer_vimgrep.new,
            qflist_previewer       = previewers.vim_buffer_qflist.new,
            layout_config          = small_layout,
            buffer_previewer_maker = previewers.buffer_previewer_maker,
            preview                = {
               filesize_limit = 5,
               treesitter     = true,
            },
            mappings               = {
               i = {
                  ['<Tab>'] = actions.move_selection_next,
                  ['<S-Tab>'] = actions.move_selection_previous,
                  ['<C-n>'] = actions.preview_scrolling_down,
                  ['<C-e>'] = actions.preview_scrolling_up,
               },
               n = {
                  ['<ESC>'] = actions.close,
                  ['<Tab>'] = actions.move_selection_next,
                  ['<S-Tab>'] = actions.move_selection_previous,
                  q = actions.close,
                  n = actions.move_selection_next,
                  e = actions.move_selection_previous,
                  m = actions.preview_scrolling_down,
                  M = actions.preview_scrolling_up,
               }
            }
         },
         pickers = {
            git_commits               = {
               initial_mode = 'normal',
               layout_config = zoom_layout_with_preview
            },
            git_bcommits              = {
               initial_mode = 'normal',
               layout_config = zoom_layout_with_preview
            },
            resume                    = { initial_mode = 'normal' },
            lsp_type_definitions      = { initial_mode = 'normal' },
            oldfiles                  = {
               mappings = insert_mappings,
            },
            live_grep                 = {
               mappings = insert_mappings,
               layout_config = zoom_layout
            },
            current_buffer_fuzzy_find = {
               mappings = insert_mappings,
               layout_config = zoom_layout_with_preview,
            },
            git_branches              = {
               mappings = insert_mappings,
               layout_config = zoom_layout,
            },
            treesitter                = {
               mappings = insert_mappings,
               layout_config = zoom_layout_with_preview,
            },
            buffers                   = {
               mappings = insert_mappings,
               layout_config = { width = medium_layout.width }
            },
            highlights                = { mappings = insert_mappings },
            keymaps                   = {
               mappings = insert_mappings,
               layout_config = zoom_layout_with_preview
            },
            command_history           = {
               mappings = insert_mappings,
               layout_config = small_layout
            },
            find_files                = {
               mappings      = insert_mappings,
               layout_config = zoom_layout_with_preview,
            },
            lsp_definitions           = {
               file_ignore_patterns = { '.git/', '.dist/' },
            },
            git_status                = {
               mappings = insert_mappings,
               layout_config = medium_layout
            }
         },
         extensions = {
            project = {},
            fzf = {
               override_generic_sorter = true,
               override_file_sorter    = true,
               case_mode               = 'smart_case',
               fuzzy                   = true
            },
         }
      }

      telescope.load_extension('fzf')
      telescope.load_extension('conflicts')
      telescope.load_extension('project')
      telescope.load_extension('gh')

      vim.api.nvim_create_autocmd(
         'BufLeave',
         {
            pattern = '*.http,*.gql,*.graphql',
            callback = function()
               map('n', '<LEADER><LEADER>', require('telescope.builtin').command_history)
            end
         }
      )
   end
}
