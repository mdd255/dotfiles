local refactor_config = {
   highlight_definitions = {
      enable = true
   },
   highlight_current_scope = {
      enable = false
   },
   smart_rename = {
      enable = false,
      keymaps = {
      }
   },
   navigation = {
      enable = false,
      keymaps = {}
   }
}

return {
   'nvim-treesitter/nvim-treesitter',
   dependencies = {
      'windwp/nvim-ts-autotag',
      'nvim-treesitter/nvim-treesitter-refactor',
      'm-demare/hlargs.nvim',
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/playground'
   },
   -- run = ':TSInstall bash go graphql http javascript typescript json lua make markdown prisma python rust sql tsx typescript vim yaml dockerfile markdown'
   run = ':TSUpdate',
   config = function()
      require 'nvim-treesitter.configs'.setup {
         ensure_installed = {
            'typescript',
            'javascript',
            'go',
            'prisma',
            'graphql',
            'bash',
            'json',
            'yaml',
            'make',
            'lua',
            'sql',
            'rust',
            'python',
            'dockerfile',
         },
         refactor         = refactor_config,
         highlight        = {
            enable = true,
            disable = { 'http' },
         },
         indent           = {
            enable = {
               'javascriptreact'
            }
         },
         autotag          = {
            enable = true
         },
         rainbow          = {
            enable         = true,
            extended_mode  = true,
            max_file_lines = 1000,
         },
      }

      vim.api.nvim_create_autocmd(
         'FileType',
         {
            pattern  = 'tsplayground',
            callback = function()
               vim.bo.sw = 2
            end
         }
      )
   end
}
