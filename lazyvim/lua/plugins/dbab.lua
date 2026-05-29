local function DB()
  vim.cmd("Dbab")
  vim.cmd("LualineRenameTab DB")
end

return {
  "mdd255/dbab.nvim",
  keys = {
    { "<Leader>d", DB, { desc = "Open DB" } },
  },
  config = function()
    require("dbab").setup({
      connections = {
        { name = "aa.local", url = "mongodb://localhost:27017/e2etester" },
        { name = "aa.staging", url = "$AA_MONGODB_STAGING" },
        { name = "bor.local", url = "postgres://postgres:postgres@localhost:5432/bor-api" },
        { name = "bor.staging", url = "$BOR_PSQL_STAGING" },
        { name = "bor.staging_v2", url = "$BOR_PSQL_STAGING_V2" },
        { name = "bor.prod", url = "$BOR_PSQL_PROD" },
        { name = "iri.local", url = "postgres://postgres:postgres@localhost:5432/roofing_local" },
        { name = "iri.staging", url = "$IRI_PSQL_STAGING" },
        { name = "redis.local", url = "redis://localhost:6379" },
      },
      layout = "classic",
      sidebar = {
        width = 0.25,
        use_brand_icon = true,
        show_system_schemas = false,
      },
      history = {
        show = false,
        width = 0.25,
      },
      editor = {
        height = 0.25,
      },
      redis = {
        command = "rdcli",
      },
      result = {
        show_line_numbers = false,
        style = "vertical",
        header_align = "full",
        height = 1,
      },
      keymaps = {
        execute = "<Cr>",
        close = "<Leader>q",
        sidebar = {
          new_query = "N",
        },
        editor = {
          next_tab = "tn",
          prev_tab = "te",
          close_tab = "tq",
        },
        result = {},
      },
    })
  end,
}
