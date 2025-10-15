return {
  {
    "neovim/nvim-lspconfig",
    keys = false,
    opts = function()
      -- delegate hightlights to treesitter
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          client.server_capabilities.semanticTokensProvider = nil
          client.server_capabilities.documentHighlightProvider = false
        end,
      })

      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "K", false }
      keys[#keys + 1] = { "gd", false }
      keys[#keys + 1] = { "gr", false }
      keys[#keys + 1] = { "gI", false }
      keys[#keys + 1] = { "gy", false }
      keys[#keys + 1] = { "gk", false }
      keys[#keys + 1] = { "gK", false }
      keys[#keys + 1] = { "gD", false }
      keys[#keys + 1] = { "<C-k>", false }
      keys[#keys + 1] = { "<Leader>ss", false }
      keys[#keys + 1] = { "<Leader>sS", false }
      keys[#keys + 1] = { "<Leader>ca", false }
      keys[#keys + 1] = { "<Leader>cc", false }
      keys[#keys + 1] = { "<Leader>cl", false }
      keys[#keys + 1] = { "<Leader>cC", false }
      keys[#keys + 1] = { "<Leader>cR", false }
      keys[#keys + 1] = { "<Leader>cr", false }
      keys[#keys + 1] = { "<Leader>cA", false }
      keys[#keys + 1] = { "[[", false }
      keys[#keys + 1] = { "]]", false }
      keys[#keys + 1] = { "<A-n>", false }
      keys[#keys + 1] = { "<A-p>", false }
      return {
        servers = {
          ts_ls = {
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "none",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = false,
                  includeInlayVariableTypeHints = false,
                  includeInlayPropertyDeclarationTypeHints = false,
                  includeInlayFunctionLikeReturnTypeHints = false,
                  includeInlayEnumMemberValueHints = false,
                },
                suggest = {
                  includeCompletionsForModuleExports = true,
                  includeCompletionsForImportStatements = true,
                },
                preferences = {
                  includePackageJsonAutoImports = "off",
                  disableSuggestions = false,
                },
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "none",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = false,
                  includeInlayVariableTypeHints = false,
                  includeInlayPropertyDeclarationTypeHints = false,
                  includeInlayFunctionLikeReturnTypeHints = false,
                  includeInlayEnumMemberValueHints = false,
                },
                suggest = {
                  includeCompletionsForModuleExports = true,
                  includeCompletionsForImportStatements = true,
                },
                preferences = {
                  includePackageJsonAutoImports = "off",
                  disableSuggestions = false,
                },
              },
            },
            init_options = {
              preferences = {
                disableSuggestions = false,
              },
            },
            capabilities = {
              documentFormattingProvider = false,
              documentRangeFormattingProvider = false,
            },
          },
        },
      }
    end,
  },
  {
    "mason-org/mason.nvim",
    keys = {
      { "<Leader>cm", false },
      { "<Leader>m", "<cmd>Mason<Cr>", desc = "Mason" },
    },
    opts = {
      ensure_installed = {
        "intelephense",
        "jdtls",
        "biome",
        "gopls",
        "json-lsp",
        "dockerfile-language-server",
        "typescript-language-server",
      },
      ui = { scrollbar = false },
    },
  },
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    keys = false,
  },
}
