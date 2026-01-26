return {
  "NickvanDyke/opencode.nvim",
  lazy = false,
  dependencies = { "folke/snacks.nvim" },
  config = function()
    vim.o.autoread = true
    vim.g.opencode_opts = {}

    vim.keymap.set({ "n", "t" }, "<C-y>", function()
      vim.notify("Opening...", vim.log.levels.INFO, { title = "Opencode" })
      vim.cmd("tabnew")
      require("opencode").toggle()
      vim.cmd("close")
    end, { desc = "Open opencode in new tab" })
  end,
}
