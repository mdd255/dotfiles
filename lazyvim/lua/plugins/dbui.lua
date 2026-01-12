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
    vim.g.db_ui_use_nerd_fonts = true
    vim.g.db_ui_show_help = false
    vim.g.db_ui_show_database_icon = true
    vim.g.db_ui_disable_progress_bar = true
    vim.g.db_ui_use_nvim_notify = true

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "mysql",
      callback = function()
        vim.opt_local.commentstring = "# %s"
        vim.keymap.set("n", "-", "<cmd>DBUIToggle<Cr>", { buffer = true })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dbout",
      callback = function()
        vim.keymap.set("n", "H", "75h", { buffer = true })
        vim.keymap.set("n", "I", "75l", { buffer = true })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dbui",
      callback = function()
        vim.keymap.set("n", "-", "<cmd>DBUIToggle<Cr>", { buffer = true })
      end,
    })
  end,
}
