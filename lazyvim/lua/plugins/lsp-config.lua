return {
  {
    "neovim/nvim-lspconfig",
    keys = false,
    opts = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local function contains(list, item)
            for _, v in ipairs(list) do
              if v == item then
                return true
              end
            end
            return false
          end

          local disabled_client_format = {
            "ts_ls",
            "vtsls",
          }

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          client.server_capabilities.semanticTokensProvider = nil
          client.server_capabilities.documentHighlightProvider = false

          -- Disable auto-formatting for TypeScript language server
          if contains(disabled_client_format, client.name) then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end
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
