return {
  {
    "neovim/nvim-lspconfig",
    keys = false,
    opts = {
      servers = {
        ["*"] = {
          keys = false,
        },
        tailwindcss = {
          filetypes = { "typescriptreact", "javascriptreact" },
        },
        lua_ls = {
          cmd = { "lua-language-server", "--maxMemoryUsage=1024" },
        },
        biome = {
          cmd = { "biome", "lsp-proxy", "--watcher-kind=none" },
          single_file_support = true,
          on_attach = function(client, _)
            client.server_capabilities.definitionProvider = false
          end,
        },
        clangd = {
          on_attach = function(client, _)
            client.server_capabilities.inlayHintProvider = false
          end,
        },
        tsgo = {
          cmd_env = { GOMEMLIMIT = "4GiB" },
          on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            client.server_capabilities.semanticTokensProvider = nil
            client.server_capabilities.documentHighlightProvider = false
          end,
          settings = {
            typescript = {
              inlayHints = {
                enumMemberValues = { enabled = false },
                functionLikeReturnTypes = { enabled = false },
                parameterNames = { enabled = "none" },
                parameterTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = false },
                variableTypes = { enabled = false },
              },
            },
          },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    keys = {
      { "<Leader>cm", false },
      { "<Leader>m", "<cmd>Mason<Cr>", desc = "Mason" },
    },
    opts = {
      ensure_installed = {
        "json-lsp",
        "biome",
        "stylua",
        "gopls",
        "tailwindcss-language-server",
        "docker-language-server",
        "tsgo",
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
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        http = {},
        python = {},
        rust = { "rustfmt", lsp_format = "fallback" },
        javascript = { "biome", stop_after_first = true },
        typescript = { "biome", stop_after_first = true },
      },
    },
  },
}
