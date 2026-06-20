local logo = require("config.logo")
local custom_layout = require("config.utils").custom_layout

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
    { "<Leader>E", false },
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
    terminal = {
      enabled = true,
      start_insert = true,
      auto_insert = false,
      auto_close = true,
    },
    explorer = { enabled = true },
    indent = { enabled = true, char = "▏" },
    styles = { notification = { wo = { wrap = true } } },
    picker = {
      prompt = " ",
      actions = {
        select_and_clear = function(picker)
          picker.list:select()
          vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, { "" })
        end,
        clear_input = function(p)
          p.input:set("")
        end,
        clear_and_focus_list = function(p)
          p.input:set("")
          p:focus("list")
        end,
        select_all = function(picker)
          local items = picker.list.items
          local all_selected = #picker.list.selected == #items
          picker.list:set_selected(all_selected and {} or items)
        end,
        cmd_execute = function(picker, item)
          picker:close()

          if item and item.cmd then
            vim.schedule(function()
              vim.cmd(item.cmd)
            end)
          end
        end,
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
        list = {
          minimal = true,
        },
        preview = {
          minimal = true,
          wo = {
            wrap = true,
          },
        },
        input = {
          minimal = true,
          keys = {
            -- <C-i> and <Tab> share the same keycode in terminals but are distinct in Neovide — intentional.
            ["<C-i>"] = { "preview_scroll_up", mode = { "n", "i" } },
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            ["<C-n>"] = { "list_down", mode = { "n", "i" } },
            ["<C-e>"] = { "list_up", mode = { "n", "i" } },
            ["<C-h>"] = { "preview_scroll_down", mode = { "n", "i" } },
            ["<C-l>"] = { "clear_input", mode = { "i" } },
            ["<C-a>"] = { "select_all", mode = { "i" } },
          },
        },
      },
      sources = {
        lsp_references = {
          include_declaration = false,
        },
        icons = {
          layout = custom_layout({
            title = " Icons",
            width = 0.5,
          }),
        },
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
          layout = custom_layout({
            title = " Projects",
            width = 0.3,
          }),
        },
        command_history = {
          confirm = "cmd_execute",
          layout = custom_layout({
            title = " Cmd history",
            width = 0.3,
          }),
        },
        files = {
          layout = custom_layout({
            title = " Files",
            width = 0.55,
          }),
          hidden = true,
          ignored = true,
          exclude = {
            "node_modules",
            ".git",
            "package-lock.json",
            "yarn.lock",
            "dist",
            "build",
          },
        },
        recent = {
          layout = custom_layout({
            title = " Recent",
            preview = true,
            preview_ratio = 0.7,
            fullscreen = true,
          }),
        },
        buffers = {
          layout = custom_layout({
            title = " Buffers",
            width = 0.55,
          }),
        },
        highlights = {
          layout = custom_layout({
            title = " Highlights",
            width = 0.8,
            preview = true,
          }),
        },
        grep = {
          hidden = true,
          ignored = true,
          exclude = {
            "node_modules",
            ".git",
            "package-lock.json",
            "yarn.lock",
            "dist",
            "build",
          },
          layout = custom_layout({
            title = " Search",
            preview = true,
            preview_ratio = 0.75,
            fullscreen = true,
          }),
        },
        git_status = {
          layout = custom_layout({
            title = " Git status",
            preview = true,
            fullscreen = true,
          }),
        },
        notifications = {
          layout = custom_layout({
            title = " Notifications",
            preview = true,
            fullscreen = true,
          }),
        },
        undo = {
          layout = custom_layout({
            title = " Undo",
            preview = true,
            fullscreen = true,
          }),
        },
        grep_word = {
          layout = custom_layout({
            title = " Search",
            preview = true,
            fullscreen = true,
          }),
        },
        keymaps = {
          layout = custom_layout({
            title = " Keymaps",
            preview = true,
            fullscreen = true,
          }),
        },
        explorer = {
          hidden = true,
          ignored = false,
          diagnostics = false,
          replace_netrw = true,
          layout = {
            fullscreen = false,
            layout = {
              width = 45,
              position = "right",
              box = "vertical",
            },
          },
          win = {
            list = {
              keys = {
                ["<C-f>"] = { "focus_input", mode = { "n" } },
                ["m"] = { "list_scroll_down", mode = { "n" } },
                ["M"] = { "list_scroll_up", mode = { "n" } },
                ["u"] = { "explorer_move", mode = { "n" } },
              },
            },
            input = {
              layout = { border = "rounded" },
              keys = {
                ["<Esc>"] = { "clear_and_focus_list", mode = { "i" } },
              },
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
    map("n", "fi", "<cmd>lua Snacks.picker.icons()<Cr>", { desc = "Find icons" })
    map("n", "fb", "<cmd>lua Snacks.picker.buffers()<Cr>", { desc = "Find buffers" })
    map("n", "fc", findConfigFileCmd, { desc = "Find config files" })
    map("n", "fr", "<cmd>lua Snacks.picker.recent()<Cr>", { desc = "Find recents" })
    map("n", "fp", "<cmd>lua Snacks.picker.projects()<Cr>", { desc = "Find projects" })
    map("n", "fk", "<cmd>lua Snacks.picker.keymaps()<Cr>", { desc = "Find keymaps" })
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

    local gh_user_cache = nil

    vim.system({ "gh", "api", "user", "-q", ".login" }, { text = true }, function(gh_result)
      if gh_result.code == 0 then
        gh_user_cache = vim.trim(gh_result.stdout or "")
      end
    end)

    vim.api.nvim_create_autocmd("DirChanged", {
      group = snacks_augroup,
      callback = function(ev)
        local new_cwd = ev.file

        vim.system({ "git", "config", "user.name" }, { text = true, cwd = new_cwd }, function(git_result)
          if git_result.code ~= 0 then
            return
          end
          local git_user = vim.trim(git_result.stdout or "")
          if git_user == "" then
            return
          end

          local function try_switch(gh_user)
            if gh_user == "" or gh_user == git_user then
              return
            end

            vim.system({ "gh", "auth", "switch", "--user", git_user }, { text = true }, function(switch_result)
              vim.schedule(function()
                if switch_result.code == 0 then
                  gh_user_cache = git_user
                  Snacks.notify(
                    string.format("gh: %s → %s", gh_user, git_user),
                    { level = vim.log.levels.INFO, title = "gh auth" }
                  )
                else
                  Snacks.notify(
                    string.format("gh switch failed: '%s' not found", git_user),
                    { level = vim.log.levels.WARN, title = "gh auth" }
                  )
                end
              end)
            end)
          end

          if gh_user_cache then
            try_switch(gh_user_cache)
          else
            vim.system({ "gh", "api", "user", "-q", ".login" }, { text = true }, function(gh_result)
              if gh_result.code ~= 0 then
                return
              end
              local gh_user = vim.trim(gh_result.stdout or "")
              gh_user_cache = gh_user
              try_switch(gh_user)
            end)
          end
        end)
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
    map({ "n", "i", "t" }, "<C-Cr>", "<cmd>lua Snacks.terminal()<Cr>", { desc = "Toggle terminal" })
    map("n", "-", "<cmd>lua Snacks.picker.explorer()<Cr>", { desc = "Toggle explorer" })
    map("n", "/", "<cmd>lua Snacks.picker.lines()<Cr>", { desc = "Grep current buffer" })
    map("n", "<Leader><Space>", "<cmd>lua Snacks.picker.resume()<Cr>", { desc = "Resume last picker" })
    map("n", "sr", "<cmd>lua Snacks.rename.rename_file()<Cr>", { desc = "Rename file (LSP-aware)" })
  end,
}
