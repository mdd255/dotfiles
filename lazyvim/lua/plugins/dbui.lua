return {
  "kristijanhusak/vim-dadbod-ui",
  lazy = true,
  keys = {
    { "<Leader>d", "<cmd>DBUI<Cr>", desc = "DBUI" },
  },
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "psql" }, lazy = true },
  },
  config = function()
    vim.g.db_ui_force_echo_notifications = false
    vim.g.db_ui_disable_info_notifications = true
    vim.db_ui_use_nerd_fonts = true
    vim.db_ui_icons = true
    vim.db_ui_show_database_icon = true
    vim.db_ui_disable_progress_bar = true

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dbout",
      callback = function()
        vim.wo.relativenumber = false
        vim.wo.number = false
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "mysql",
      callback = function()
        vim.opt_local.commentstring = "# %s"
      end,
    })
  end,
}
