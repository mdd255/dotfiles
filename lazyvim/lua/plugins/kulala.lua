return {
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "gc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = "http" },
      { "gp", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = "http" },
      {
        "gd",
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = "Download GraphQL schema",
        ft = "http",
      },
      { "gi", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request", ft = "http" },
      { "gn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
      { "ge", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" },
      { "go", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
      { "gh", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = "http" },
    },
    opts = {},
  },
}
