---@diagnostic disable: undefined-global
local git = require("config.git-functions")

return {
  {
    "sindrets/diffview.nvim",
    lazy = false,
    keys = {
      { "gdi", "<cmd>DiffviewOpen<Cr>", desc = "Diffview open" },
      { "glo", "<cmd>DiffviewFileHistory<Cr>", desc = "Git log" },
      { "gpb", "<cmd>lua Snacks.gitbrowse()<Cr>", desc = "Git open file in browser" },
      {
        "gpf",
        function()
          git.git_push(true)
        end,
        desc = "Git push force",
      },
      {
        "gpp",
        function()
          git.git_fetch()
        end,
        desc = "Git fetch prune",
      },
    },
    config = function()
      local actions = require("diffview.actions")

      local function stage_all()
        actions.stage_all()
        vim.notify("Git: staged all files")
      end

      local function update_diffview_progress()
        local view = require("diffview.lib").get_current_view()

        if not view or not view.panel then
          return
        end

        local file_dict = view.panel.files

        if not file_dict then
          return
        end

        local files = {}
        vim.list_extend(files, file_dict.working or {})
        vim.list_extend(files, file_dict.staged or {})
        vim.list_extend(files, file_dict.conflicting or {})

        local total = #files

        if total == 0 then
          return
        end

        -- diffview API varies by version: panel.cur_file or view.cur_file
        local cur = view.panel.cur_file or view.cur_file

        if cur then
          for i, f in ipairs(files) do
            local path_match = f.path and cur.path and f.path == cur.path
            local abs_match = f.absolute_path and cur.absolute_path and f.absolute_path == cur.absolute_path
            if f == cur or path_match or abs_match then
              vim.g.diffview_progress = "[" .. i .. "/" .. total .. "]"
              vim.cmd("redrawtabline")
              return
            end
          end
        end

        vim.g.diffview_progress = "[1/" .. total .. "]"
        vim.cmd("redrawtabline")
      end

      local blame_was_on = false

      local opts = {
        enhanced_diff_hl = true,
        hooks = {
          view_opened = function()
            vim.g.diffview_tab = vim.api.nvim_tabpage_get_number(0)

            vim.defer_fn(function()
              vim.g.diffview_active = true
              update_diffview_progress()

              local gs_ok, gs = pcall(require, "gitsigns")
              if gs_ok then
                local cfg_ok, cfg = pcall(require, "gitsigns.config")
                if cfg_ok then
                  blame_was_on = cfg.config.current_line_blame
                  if blame_was_on then
                    gs.toggle_current_line_blame()
                  end
                end
              end

              for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                vim.api.nvim_set_option_value("number", false, { win = win })
                vim.api.nvim_set_option_value("relativenumber", false, { win = win })
                vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
                vim.api.nvim_set_option_value("statuscolumn", "", { win = win })
              end
            end, 200)
          end,

          view_post_layout = function()
            vim.g.diffview_tab = vim.g.diffview_tab or vim.api.nvim_tabpage_get_number(0)
            vim.schedule(update_diffview_progress)
          end,

          diff_buf_win_enter = function()
            vim.schedule(update_diffview_progress)
          end,

          view_closed = function()
            vim.g.diffview_active = false
            vim.g.diffview_progress = nil
            vim.g.diffview_tab = nil

            if blame_was_on then
              local gs_ok, gs = pcall(require, "gitsigns")
              if gs_ok then
                gs.toggle_current_line_blame()
              end
              blame_was_on = false
            end
          end,
        },
        view = {
          default = {
            layout = "diff2_horizontal",
          },
        },
        file_panel = {
          listing_style = "list",
          win_config = {
            position = "bottom",
            height = 10,
          },
        },
        keymaps = {
          view = {
            { "n", "<Leader>q", git.close_diffview, { desc = "DiffviewClose" } },
            { "n", "-", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "S", stage_all, { desc = "Stage all" } },
            {
              "n",
              "<Tab>",
              function()
                actions.select_next_entry()
                vim.schedule(update_diffview_progress)
              end,
              { desc = "Next file" },
            },
            {
              "n",
              "<S-Tab>",
              function()
                actions.select_prev_entry()
                vim.schedule(update_diffview_progress)
              end,
              { desc = "Prev file" },
            },
            { "n", "gcn", actions.next_conflict, { desc = "Goto next conflict" } },
            { "n", "gce", actions.prev_conflict, { desc = "Goto prev conflict" } },
            { "n", "gco", actions.conflict_choose_all("ours"), { desc = "Git conflict choose ours" } },
            { "n", "gct", actions.conflict_choose_all("theirs"), { desc = "Git conflict choose theirs" } },
            { "n", "gca", actions.conflict_choose_all("all"), { desc = "Git conflict choose all" } },
            { "n", "gcN", actions.conflict_choose_all("none"), { desc = "Git conflict choose none" } },
            { "n", "gcb", actions.conflict_choose_all("base"), { desc = "Git conflict choose base" } },
          },
          file_panel = {
            { "n", "-", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "<Leader>q", git.close_diffview, { desc = "DiffviewClose" } },
            { "n", "<Esc>", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "S", stage_all, { desc = "Stage all" } },
            { "n", "s<Cr>", git.git_commit, { desc = "Git commit" } },
            { "n", "sA", git.git_commit_amend, { desc = "Git commit amend" } },
          },
          file_history_panel = {
            { "n", "<Leader>q", git.close_diffview, { desc = "DiffviewClose" } },
            { "n", "-", actions.toggle_files, { desc = "Toggle file explorer" } },
            { "n", "<Esc>", actions.toggle_files, { desc = "Toggle file explorer" } },
          },
        },
      }

      require("diffview").setup(opts)
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    opts = {
      current_line_blame = true,
      current_line_blame_formatter = "    <author> - <author_time:%R> - <summary>",
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "│" },
        topdelete = { text = "│" },
        changedelete = { text = "│" },
        untracked = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function nmap(lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set("n", lhs, rhs, opts)
        end

        nmap("gn", function()
          gitsigns.nav_hunk("next")
        end, { desc = "Go to next hunk" })

        nmap("ge", function()
          gitsigns.nav_hunk("prev")
        end, { desc = "Go to prev hunk" })

        nmap("gq", gitsigns.reset_hunk, { desc = "Reset hunk" })
        nmap("gQ", gitsigns.reset_buffer, { desc = "Reset buffer" })

        nmap("gi", gitsigns.preview_hunk, { desc = "Preview hunk" })
        nmap("gI", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
      end,
    },
  },
}
