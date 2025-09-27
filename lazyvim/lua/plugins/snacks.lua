return {
  "snacks.nvim",
  opts = {
    indent = { enabled = true },
    animate = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = false },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = false },
    scratch = {
      name = "Code playground",
      win_by_ft = {
        lua = {
          keys = {
            ["source"] = {
              "<Cr>",
              function(self)
                local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                Snacks.debug.run({ buf = self.buf, name = name })
              end,
              desc = "Source buffer",
              mode = { "n", "i" },
            },
          },
        },
      },
    },
    picker = {
      matcher = {
        cwd_bonus = true,
        frecency = true,
      },
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            ["<Tab>"] = { "list_down", mode = { "n", "i" } },
            ["<S-Tab>"] = { "list_up", mode = { "n", "i" } },
            ["<C-n>"] = { "preview_scroll_down", mode = { "n", "i" } },
            ["<C-e>"] = { "preview_scroll_up", mode = { "n", "i" } },
          },
        },
      },
    },
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
    { "<Leader>sR", false },
    { "<Leader>sM", false },
    { "<Leader>sm", false },
    { "<Leader>sq", false },
    { "<Leader>su", false },
    { "<Leader>dps", false },
    { "<Leader>S", false },
    { "<Leader>uC", false },
    { "<Leader>un", false },
    -- finder keys
    { "ff", "<cmd>lua Snacks.picker.files()<Cr>", desc = "Find files" },
    { "fb", "<cmd>lua Snacks.picker.buffers()<Cr>", desc = "Find buffers" },
    { "fc", "<cmd>lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })<Cr>", desc = "Find config files" },
    { "fs", "<cmd>lua Snacks.picker.grep()<Cr>", desc = "Grep" },
    { "fr", "<cmd>lua Snacks.picker.recent()<Cr>", desc = "Find recents" },
    { "fp", "<cmd>lua Snacks.picker.projects()<Cr>", { desc = "Find projects" } },
    { "fk", "<cmd>lua Snacks.picker.keymaps()<Cr>", desc = "Find keymaps" },
    { "fm", "<cmd>lua Snacks.picker.marks()<Cr>", desc = "Find marks" },
    { "fh", "<cmd>lua Snacks.picker.highlights()<Cr>", desc = "Find highlights" },
    -- git keymaps
    { "gbr", "<cmd>lua Snacks.picker.git_branches()<Cr>", desc = "Git branches" },
    { "glo", "<cmd>lua Snacks.picker.git_log()<Cr>", desc = "Git log" },
    { "glf", "<cmd>lua Snacks.picker.git_log_file()<Cr>", desc = "Git log files" },
    { "gst", "<cmd>lua Snacks.picker.git_status()<Cr>", desc = "Git status" },
    { "gdi", "<cmd>lua Snacks.picker.git_diff()<Cr>", desc = "Git diff" },
    { "gss", "<cmd>lua Snacks.picker.git_stash()<Cr>", desc = "Git stash" },
    { "gbb", "<cmd>lua Snacks.gitbrowse()<Cr>", desc = "Git open file in browser" },
    -- misc keymaps
    { "<Leader>g", "<cmd>lua Snacks.lazygit()<Cr>", desc = "Open Lazygit" },
    { "<C-Cr>", "<cmd>lua Snacks.terminal()<Cr>", desc = "Toggle terminal" },
    { "-", "<cmd>lua Snacks.picker.explorer()<Cr>", desc = "Toggle explorer" },
    { "<Cr>", "<cmd>lua Snacks.picker.commands()<Cr>", desc = "Find commands" },
    { "/", "<cmd>lua Snacks.picker.lines()<Cr>", desc = "Grep current buffer" },
    { "<Space><Space>", "<cmd>lua Snacks.picker.resume()<Cr>", desc = "Resume last picker" },
    -- lsp keymaps
    { "tt", "<cmd>lua Snacks.picker.lsp_definitions()<Cr>", desc = "Go to definitions" },
    { "tf", "<cmd>lua Snacks.picker.lsp_references()<Cr>", desc = "Go to references" },
    { "ts", "<cmd>lua Snacks.picker.lsp_symbols()<Cr>", desc = "LSP symbols" },
    { "tS", "<cmd>lua Snacks.picker.lsp_workspace_symbols()<Cr>", desc = "Workspace LSP symbols" },
    { "th", "<cmd>lua vim.lsp.buf.hover({border='rounded'})<Cr>", desc = "LSP hover" },
    { "tr", "<cmd>lua vim.lsp.buf.rename()<Cr>", desc = "LSP rename" },
    { "ta", "<cmd>lua Snacks.picker.diagnostics_buffer()<Cr>", desc = "LSP disagnostics" },
    { "tA", "<cmd>lua Snacks.picker.diagnostics()<Cr>", desc = "Workspace LSP disagnostics" },
  },
}
