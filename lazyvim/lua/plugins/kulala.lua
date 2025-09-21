return {
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "ty", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = "http" },
      { "tp", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = "http" },
      {
        "td",
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = "Download GraphQL schema",
        ft = "http",
      },
      { "th", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request", ft = "http" },
      { "tn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
      { "te", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" },
      { "tt", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
      { "ts", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = "http" },
    },
    opts = {},
  },
}
