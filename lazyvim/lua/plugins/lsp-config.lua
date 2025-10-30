return {
  {
    "neovim/nvim-lspconfig",
    keys = false,
    opts = {
      servers = {
        ["*"] = {
          keys = false,
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
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        rust = { "rustfmt", lsp_format = "fallback" },
        javascript = { "biome", stop_after_first = true },
      },
    },
  },
}
