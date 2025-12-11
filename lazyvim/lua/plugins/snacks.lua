return {
  "folke/snacks.nvim",
  keys = function()
    return {}
  end,
  opts = {
    toggle = { enabled = false },
    scope = { enabled = false },
    image = { enabled = false },
    zen = { enabled = false },
    scratch = { enabled = false },
    words = { enabled = false },
    indent = { enabled = true },
    animate = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = { enabled = true },
    explorer = { enabled = true },
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
      sources = {
        projects = {
          format = "file",
          recent = true,
          confirm = "load_session",
          patterns = {
            ".git",
            "package.json",
          },
          dev = {
            "~/.config/",
            "~/Projects/",
          },
        },
        files = { hidden = true },
        grep = { hidden = true },
        explorer = {
          hidden = false,
          ignored = true,
          diagnostics = false,
          replace_netrw = true,
          layout = {
            layout = {
              width = 40,
              position = "left",
              box = "vertical",
              { win = "list" },
              { win = "input", height = 1 },
            },
          },
        },
      },
    },
    dashboard = {
      preset = {
        keys = {
          { icon = "", key = "o", desc = "Restore Session", section = "session" },
          { icon = "", key = "q", desc = "Quit", action = ":qa" },
        },
        header = [[
                _     _ ___  _____ _____
                 | |   | |__ \| ____| ____|
  _ __ ___   __| | __| |  ) | |__ | |__
 | '_ ` _ \_/ _` |/ _` | / /|___ \|___ \
   | | | | | | (_| | (_| |/ /_ ___)  ___) |
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
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    local map = vim.keymap.set
    local findConfigFileCmd = "<cmd>lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })<Cr>"

    -- finder keys
    map("n", "ff", "<cmd>lua Snacks.picker.files()<Cr>", { desc = "Find files" })
    map("n", "fb", "<cmd>lua Snacks.picker.buffers()<Cr>", { desc = "Find buffers" })
    map("n", "fc", findConfigFileCmd, { desc = "Find config files" })
    map("n", "fs", "<cmd>lua Snacks.picker.grep()<Cr>", { desc = "Grep" })
    map("n", "fr", "<cmd>lua Snacks.picker.recent()<Cr>", { desc = "Find recents" })
    map("n", "fp", "<cmd>lua Snacks.picker.projects()<Cr>", { desc = "Find projects" })
    map("n", "fk", "<cmd>lua Snacks.picker.keymaps()<Cr>", { desc = "Find keymaps" })
    map("n", "fm", "<cmd>lua Snacks.picker.marks()<Cr>", { desc = "Find marks" })
    map("n", "fh", "<cmd>lua Snacks.picker.highlights()<Cr>", { desc = "Find highlights" })

    -- git keymaps
    map("n", "gbr", "<cmd>lua Snacks.picker.git_branches()<Cr>", { desc = "Git branches" })
    map("n", "glo", "<cmd>lua Snacks.picker.git_log()<Cr>", { desc = "Git log" })
    map("n", "glf", "<cmd>lua Snacks.picker.git_log_file()<Cr>", { desc = "Git log files" })
    map("n", "gst", "<cmd>lua Snacks.picker.git_status()<Cr>", { desc = "Git status" })
    map("n", "gdi", "<cmd>lua Snacks.picker.git_diff()<Cr>", { desc = "Git diff" })
    map("n", "gss", "<cmd>lua Snacks.picker.git_stash()<Cr>", { desc = "Git stash" })
    map("n", "gbb", "<cmd>lua Snacks.gitbrowse()<Cr>", { desc = "Git open file in browser" })

    -- misc keymaps
    map("n", "<C-Cr>", "<cmd>lua Snacks.terminal()<Cr>", { desc = "Toggle terminal" })
    map("n", "-", "<cmd>lua Snacks.picker.explorer()<Cr>", { desc = "Toggle explorer" })
    map("n", "/", "<cmd>lua Snacks.picker.lines()<Cr>", { desc = "Grep current buffer" })
    map("n", "<Leader><Space>", "<cmd>lua Snacks.picker.resume()<Cr>", { desc = "Resume last picker" })

    -- LSP keymaps
    map("n", "tn", "<cmd>lua vim.diagnostic.goto_next()<Cr>", { desc = "Go to next diagnostics" })
    map("n", "te", "<cmd>lua vim.diagnostic.goto_prev()<Cr>", { desc = "Go to prev diagnostics" })
    map("n", "t<Cr>", "<cmd>lua vim.lsp.buf.code_action()<Cr>", { desc = "Code action" })
    map("n", "th", "<cmd>lua vim.lsp.buf.hover({border='rounded'})<Cr>", { desc = "LSP hover" })
    map("n", "tr", "<cmd>lua vim.lsp.buf.rename()<Cr>", { desc = "LSP rename" })
    map("n", "tt", "<cmd>lua Snacks.picker.lsp_definitions()<Cr>", { desc = "Go to definitions" })
    map("n", "tf", "<cmd>lua Snacks.picker.lsp_references()<Cr>", { desc = "Go to references" })
    map("n", "ts", "<cmd>lua Snacks.picker.lsp_symbols()<Cr>", { desc = "LSP symbols" })
    map("n", "tS", "<cmd>lua Snacks.picker.lsp_workspace_symbols()<Cr>", { desc = "Workspace LSP symbols" })
    map("n", "ta", "<cmd>lua Snacks.picker.diagnostics_buffer()<Cr>", { desc = "LSP diagnostics" })
    map("n", "tA", "<cmd>lua Snacks.picker.diagnostics()<Cr>", { desc = "Workspace LSP diagnostics" })
  end,
}
