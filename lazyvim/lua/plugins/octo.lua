return {
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
}
