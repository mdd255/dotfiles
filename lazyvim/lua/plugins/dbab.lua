return {
  "mdd255/dbab.nvim",
  config = function()
    require("dbab").setup({
      connections = {
        { name = "iri.local", url = "postgres://postgres:postgrer@localhost:5432/roofing_local" },
        { name = "aa.local", url = "mongodb://localhost:27017/e2etester" },
        { name = "aa.staging", url = "$AA_MONGODB_STAGING" },
        { name = "iri.staging", url = "$IRI_PSQL_STAGING" },
      },
      layout = "classic",
      sidebar = {
        width = 0.25,
        use_brand_icon = true,
        show_system_schemas = false,
      },
      history = {
        show = false,
      },
      editor = {
        height = 0.25,
      },
      result = {
        show_line_numbers = false,
        style = "vertical",
        header_align = "full",
        height = 0.75,
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

    local map = vim.keymap.set

    map("n", "<Leader>d", function()
      vim.cmd("Dbab")
      vim.cmd("LualineRenameTab DB")
    end, { desc = "Open DB" })
  end,
}
