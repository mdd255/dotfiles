local logo = require("config.logo")

return {
  "folke/snacks.nvim",
  lazy = false,
  keys = {
    { "<Leader>ff", false },
    { "<Leader>fb", false },
    { "<Leader>fB", false },
    { "<Leader>fc", false },
    { "<Leader>fe", false },
    { "<Leader>fE", false },
    { "<Leader>fF", false },
    { "<Leader>fg", false },
    { "<Leader>fp", false },
    { "<Leader>fr", false },
    { "<Leader>fR", false },
    { "<Leader>un", false },
    { "<Leader>uC", false },
    { "<Leader>/", false },
    { "<Leader>.", false },
    { "<Leader>,", false },
    { "<Leader>S", false },
    { "<Leader>Q", false },
    { "<Leader>:", false },
    { "<Leader>gd", false },
    { "<Leader>gD", false },
    { "<Leader>gi", false },
    { "<Leader>gI", false },
    { "<Leader>gp", false },
    { "<Leader>gP", false },
    { "<Leader>gs", false },
    { "<Leader>gS", false },
    { "<Leader>dps", false },
  },
  opts = {
    toggle = { enabled = false },
    scope = { enabled = false },
    image = { enabled = false },
    zen = { enabled = false },
    win = { enabled = false },
    scratch = { enabled = true },
    words = { enabled = false },
    animate = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false },
    terminal = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = true, char = "▏" },
    picker = {
      layout = {
        layout = {
          box = "vertical",
          width = 0.9,
          height = 0.8,
          border = "rounded",
          title = "{title} {live} {flags}",
          { win = "input", height = 1, border = "bottom" },
          { win = "list", border = "none" },
        },
      },
      formatters = {
        file = {
          show_idx = false,
        },
      },
      matcher = {
        cwd_bonus = true,
        frecency = true,
      },
      win = {
        preview = {
          wo = {
            number = false,
            relativenumber = false,
          },
        },
        input = {
          wo = {
            signcolumn = "yes:1",
          },
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            ["<C-n>"] = { "list_down", mode = { "n", "i" } },
            ["<C-e>"] = { "list_up", mode = { "n", "i" } },
            ["<C-h>"] = { "preview_scroll_down", mode = { "n", "i" } },
            -- <C-i> and <Tab> share the same keycode in terminals but are distinct in Neovide — intentional.
            ["<C-i>"] = { "preview_scroll_up", mode = { "n", "i" } },
          },
        },
      },
      sources = {
        lsp_symbols = {},
        projects = {
          format = "project_name",
          recent = true,
          confirm = "load_session",
          patterns = {
            ".git",
            "package.json",
          },
          dev = {
            "~/.config/dotfiles/",
            "~/Projects/priv/",
            "~/Projects/ABD/",
            "~/Projects/hipages/",
            "~/Projects/accelerator-app/",
          },
          layout = {
            layout = {
              width = 0.4,
              height = 0.4,
              box = "vertical",
              border = "rounded",
              title = "  Projects",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
            },
          },
        },
        files = {
          hidden = true,
          layout = {
            layout = { title = " Files" },
          },
        },
        grep = {
          hidden = true,
          layout = {
            layout = { title = " Search" },
          },
        },
        explorer = {
          hidden = true,
          ignored = false,
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
        header = logo,
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

    Snacks.picker.format.project_name = function(item, _opts)
      local path = item.file or item.cwd or ""
      local name = vim.fn.fnamemodify(path, ":t")
      return { { name, "SnacksPickerFile" } }
    end

    Snacks.picker.format.ui_select = function(_opts)
      _opts = _opts or {}
      local format_item = _opts.format_item or tostring

      return function(item)
        return { { format_item(item.item) } }
      end
    end

    vim.ui.select = Snacks.picker.select

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
    map({ "n", "x" }, "fw", "<cmd>lua Snacks.picker.grep_word()<Cr>", { desc = "Grep word/selection" })
    map("n", "fo", "<cmd>lua Snacks.picker.command_history()<Cr>", { desc = "Find command history" })
    map("n", "fu", "<cmd>lua Snacks.picker.undo()<Cr>", { desc = "Find undo history" })
    map("n", "fn", "<cmd>lua Snacks.picker.notifications()<Cr>", { desc = "Find notifications" })

    local snacks_augroup = vim.api.nvim_create_augroup("SnacksConfig", { clear = true })

    vim.api.nvim_create_autocmd("WinEnter", {
      group = snacks_augroup,
      callback = function()
        if vim.bo.filetype == "snacks_picker_input" and vim.fn.mode():sub(1, 1) ~= "i" then
          vim.schedule(function()
            if vim.bo.filetype == "snacks_picker_input" then
              vim.cmd("startinsert!")
            end
          end)
        end
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = snacks_augroup,
      pattern = "claudecode",
      callback = function(ev)
        map("t", "<C-Cr>", function()
          Snacks.scratch()

          vim.schedule(function()
            vim.opt_local.ft = "text"
            vim.opt_local.number = false
            vim.opt_local.statuscolumn = ""

            local buf = vim.api.nvim_get_current_buf()

            local function accept_scratch()
              vim.cmd("%y+")
              vim.cmd("close")

              vim.schedule(function()
                vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
              end)
            end

            local map_opts = { buffer = buf, nowait = true, silent = true }
            map({ "i", "n" }, "<C-Cr>", accept_scratch, map_opts)

            map("n", "<Esc>", function()
              vim.cmd("close")
            end, map_opts)
          end)
        end, { buffer = ev.buf, desc = "Open scratch float from terminal" })
      end,
    })

    -- misc keymaps
    map("n", "<C-Cr>", "<cmd>lua Snacks.terminal()<Cr>", { desc = "Toggle terminal" })
    map("n", "-", "<cmd>lua Snacks.picker.explorer()<Cr>", { desc = "Toggle explorer" })
    map("n", "/", "<cmd>lua Snacks.picker.lines()<Cr>", { desc = "Grep current buffer" })
    map("n", "<Leader><Space>", "<cmd>lua Snacks.picker.resume()<Cr>", { desc = "Resume last picker" })
    map("n", "sr", "<cmd>lua Snacks.rename.rename_file()<Cr>", { desc = "Rename file (LSP-aware)" })

    -- LSP keymaps
    map("n", "tn", "<cmd>lua vim.diagnostic.goto_next()<Cr>", { desc = "Go to next diagnostics" })
    map("n", "te", "<cmd>lua vim.diagnostic.goto_prev()<Cr>", { desc = "Go to prev diagnostics" })
    map("n", "t<Cr>", "<cmd>lua vim.lsp.buf.code_action()<Cr>", { desc = "Code action" })
    map("n", "th", "<cmd>lua vim.lsp.buf.hover({border='rounded'})<Cr>", { desc = "LSP hover" })
    map("n", "tr", "<cmd>lua vim.lsp.buf.rename()<Cr>", { desc = "LSP rename" })
    map("n", "tt", "<cmd>lua Snacks.picker.lsp_definitions()<Cr>", { desc = "Go to definitions" })
    map("n", "ti", "<cmd>lua Snacks.picker.lsp_implementations()<Cr>", { desc = "Go to implementations" })
    map("n", "td", "<cmd>lua Snacks.picker.lsp_type_definitions()<Cr>", { desc = "Go to type definitions" })
    map("n", "tf", "<cmd>lua Snacks.picker.lsp_references()<Cr>", { desc = "Go to references" })
    map("n", "ts", "<cmd>lua Snacks.picker.lsp_symbols()<Cr>", { desc = "LSP symbols" })
    map("n", "tS", "<cmd>lua Snacks.picker.lsp_workspace_symbols()<Cr>", { desc = "Workspace LSP symbols" })
    map("n", "ta", "<cmd>lua Snacks.picker.diagnostics_buffer()<Cr>", { desc = "LSP diagnostics" })
    map("n", "tA", "<cmd>lua Snacks.picker.diagnostics()<Cr>", { desc = "Workspace LSP diagnostics" })
  end,
}
