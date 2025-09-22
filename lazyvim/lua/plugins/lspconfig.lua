return {
  {
    "neovim/nvim-lspconfig",
    keys = false,
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "K", false }
      keys[#keys + 1] = { "gd", false }
      keys[#keys + 1] = { "gr", false }
      keys[#keys + 1] = { "gI", false }
      keys[#keys + 1] = { "gy", false }
      keys[#keys + 1] = { "gk", false }
      keys[#keys + 1] = { "<C-k>", false }
      keys[#keys + 1] = { "<Leader>ss", false }
      keys[#keys + 1] = { "<Leader>SS", false }
    end,
  },
  {
    "mason-org/mason.nvim",
    keys = {
      { "<Leader>m", "<cmd>Mason<Cr>", desc = "Mason" },
    },
    opts = {
      ensure_installed = {
        "intelephense",
        "jdtls",
        "vtsls",
        "biome",
        "gopls",
        "json-lsp",
        "dockerfile-language-server",
      },
      ui = { scrollbar = false },
    },
  },
}
