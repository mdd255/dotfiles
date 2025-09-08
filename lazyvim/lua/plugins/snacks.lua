return {
  "snacks.nvim",
  opts = {
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false },
    toggle = { map = LazyVim.safe_keymap_set },
    words = { enabled = true },
  },
  keys = {
    {
      "ff",
      function()
        Snacks.picker.files()
      end,
    },
    {
      "fc",
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
      end,
    },
    {
      "fs",
      function()
        Snacks.picker.grep()
      end,
    },
    {
      "fr",
      function()
        Snacks.picker.recent()
      end,
    },
    {
      "fp",
      function()
        Snacks.picker.projects()
      end,
    },
    {
      "-",
      function()
        Snacks.picker.explorer()
      end,
    },
    {
      "<Cr>",
      function()
        Snacks.picker.commands()
      end,
    },
    {
      "fk",
      function()
        Snacks.picker.keymaps()
      end,
    },
    {
      "fm",
      function()
        Snacks.picker.marks()
      end,
    },
    {
      "<Space><Space>",
      function()
        Snacks.picker.resume()
      end,
    },
  },
}
