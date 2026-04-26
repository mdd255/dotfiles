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
        clangd = {
          on_attach = function(client, _)
            client.server_capabilities.inlayHintProvider = false
          end,
        },
        tsgo = {
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
        python = {},
        rust = { "rustfmt", lsp_format = "fallback" },
        javascript = { "biome", stop_after_first = true },
        typescript = { "biome", stop_after_first = true },
      },
    },
  },
}
