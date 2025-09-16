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
    dashboard = {
      preset = {
        keys = {
          { icon = "", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          {
            icon = "",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = "", key = "s", desc = "Restore Session", section = "session" },
          { icon = "", key = "q", desc = "Quit", action = ":qa" },
        },
        header = [[
                _     _ ___  _____ _____ 
               | |   | |__ \| ____| ____|
  _ __ ___   __| | __| |  ) | |__ | |__  
 | '_ ` _ \ / _` |/ _` | / /|___ \|___ \ 
 | | | | | | (_| | (_| |/ /_ ___) |___) |
 |_| |_| |_|\__,_|\__,_|____|____/|____/ 
                                         
                                         
        ]],
      },
      sections = {
        { section = "header" },
        { icon = "", title = "Menu", section = "keys", indent = 5, padding = 1, gap = 0 },
        { icon = "", title = "Recent Projects", section = "projects", indent = 5, padding = 1, gap = 0 },
        { icon = "", title = "Recent Files", section = "recent_files", indent = 5, padding = 1, gap = 0 },
      },
    },
    terminal = {
      enabled = true,
    },
  },
  keys = {
    -- disable default keymaps
    { "<Leader>E", false },
    { "<Leader>fe", false },
    { "<Leader>fE", false },
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
    -- finder keys
    {
      "ff",
      function()
        Snacks.picker.files()
      end,
      desc = "Find files",
    },
    {
      "fb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Find buffers",
    },
    {
      "fc",
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Find config files",
    },
    {
      "fs",
      function()
        Snacks.picker.grep_lines()
      end,
      desc = "Grep",
    },
    {
      "fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Find recents",
    },
    {
      "fp",
      function()
        Snacks.picker.projects()
      end,
      { desc = "Find projects" },
    },
    {
      "fk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Find keymaps",
    },
    {
      "fm",
      function()
        Snacks.picker.marks()
      end,
      desc = "Find marks",
    },
    {
      "fh",
      function()
        Snacks.picker.highlights()
      end,
      desc = "Find highlights",
    },
    -- git keymaps
    {
      "gbr",
      function()
        Snacks.picker.git_branches()
      end,
      desc = "Git branches",
    },
    {
      "glo",
      function()
        Snacks.picker.git_log()
      end,
      desc = "Git log",
    },
    {
      "glf",
      function()
        Snacks.picker.git_log_file()
      end,
      desc = "Git log files",
    },
    {
      "gst",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git status",
    },
    {
      "gdi",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Git diff",
    },
    {
      "gss",
      function()
        Snacks.picker.git_stash()
      end,
      desc = "Git stash",
    },
    {
      "gbb",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git open file in browser",
    },
    -- misc keymaps
    {
      "g<Cr>",
      function()
        Snacks.lazygit()
      end,
      desc = "Open Lazygit",
    },
    {
      "<C-Cr>",
      function()
        Snacks.terminal()
      end,
      desc = "Toggle terminal",
    },
    {
      "-",
      function()
        Snacks.picker.explorer()
      end,
      desc = "Toggle explorer",
    },
    {
      "<Cr>",
      function()
        Snacks.picker.commands()
      end,
      desc = "Find commands",
    },
    {
      "/",
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = "Grep buffer",
    },
    {
      "<Space><Space>",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume last picker",
    },
    -- lsp keymaps
    {
      "tt",
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = "Go to definitions",
    },
    {
      "tf",
      function()
        Snacks.picker.lsp_references()
      end,
      desc = "Go to references",
    },
    {
      "ts",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "LSP symbols",
    },
    {
      "tS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "Workspace LSP symbols",
    },
    {
      "ta",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "LSP disagnostics",
    },
    {
      "tA",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Workspace LSP disagnostics",
    },
  },
}
