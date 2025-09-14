return {
  {
    "neovim/nvim-lspconfig",
    opts = {},
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "vtsls",
        "biome",
        "gopls",
        "json-lsp",
        "dockerfile-language-server",
      },
    },
  },
}
