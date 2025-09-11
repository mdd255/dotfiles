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
    picker = { enabled = true },
  },
  keys = {
    { "<Leader>,", false },
    { "<Leader>/", false },
    { "<Leader>:", false },
    { "<Leader>n", false },
    { "<Leader>fb", false },
    { "<Leader>fB", false },
    { "<Leader>fc", false },
    { "<Leader>ff", false },
    { "<Leader>fF", false },
    { "<Leader>fg", false },
    { "<Leader>fr", false },
    { "<Leader>fR", false },
    { "<Leader>fp", false },
    { "<Leader>gd", false },
    { "<Leader>gs", false },
    { "<Leader>gS", false },
    { "<Leader>sb", false },
    { "<Leader>sB", false },
    { "<Leader>sg", false },
    { "<Leader>sG", false },
    { "<Leader>sp", false },
    { "<Leader>sw", false },
    { "<Leader>sW", false },
    { '<Leader>s"', false },
    { "<Leader>s/", false },
    { "<Leader>sa", false },
    { "<Leader>sc", false },
    { "<Leader>sC", false },
    { "<Leader>sd", false },
    { "<Leader>sD", false },
    { "<Leader>sh", false },
    { "<Leader>sH", false },
    { "<Leader>si", false },
    { "<Leader>sj", false },
    { "<Leader>sk", false },
    { "<Leader>sl", false },
    { "<Leader>sM", false },
    { "<Leader>sm", false },
    { "<Leader>sq", false },
    { "<Leader>su", false },
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
        Snacks.picker.command_history()
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
    {
      "gbr",
      function()
        Snacks.picker.git_branches()
      end,
    },
    {
      "glo",
      function()
        Snacks.picker.git_log()
      end,
    },
    {
      "glf",
      function()
        Snacks.picker.git_log_file()
      end,
    },
    {
      "gst",
      function()
        Snacks.picker.git_status()
      end,
    },
    {
      "gdi",
      function()
        Snacks.picker.git_diff()
      end,
    },
    {
      "gss",
      function()
        Snacks.picker.git_stash()
      end,
    },
    {
      "lg",
      function()
        Snacks.lazygit()
      end,
    },
  },
}
