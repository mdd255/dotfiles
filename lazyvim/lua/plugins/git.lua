return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_formatter = "   <author> - <author_time:%R> [<summary>]",
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function nmap(lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set("n", lhs, rhs, opts)
        end

        nmap("gn", function()
          if vim.wo.diff then
            vim.cmd.normal({ "gn", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Go to next hunk" })

        nmap("ge", function()
          if vim.wo.diff then
            vim.cmd.normal({ "ge", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Go to prev hunk" })

        nmap("gq", gitsigns.reset_hunk, { desc = "Reset hunk" })
        nmap("gQ", gitsigns.reset_buffer, { desc = "Reset buffer" })

        nmap("gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
        nmap("gS", gitsigns.stage_buffer, { desc = "Stage buffer" })

        nmap("gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
        nmap("gP", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
      end,
    },
  },
  {
    "pwntester/octo.nvim",
    lazy = true,
    keys = {
      { "<Leader>o", "<cmd>Octo<Cr>", desc = "Octo" },
    },
    opts = {
      picker = "snacks",
      ssh_aliases = {
        ["git-hp"] = "github.com",
        ["git-abd"] = "github.com",
      },
    },
  },
}
