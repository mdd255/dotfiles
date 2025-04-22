return {
   'sindrets/diffview.nvim',
   cmd = { 'DiffviewOpen' },
   config = function()
      local actions = require('diffview.actions')

      local keymaps = {
         select_next_entry      = '<TAB>',
         select_prev_entry      = '<S-TAB>',
         select_entry           = '<CR>',
         restore_buf            = 'X',
         next_conflict          = 'cn',
         prev_conflict          = 'ce',
         conflict_choose_all    = 'ca',
         conflict_choose_ours   = 'co',
         conflict_choose_theirs = 'ct',
         conflict_choose_base   = 'cb',
         conflict_choose_none   = 'cn',
         goto_file_tab          = 'o',
         toggle_files           = 'T',
         cycle_layout           = 'l',
         toggle_stage_entry     = 's',
         stage_all              = 'S',
         unstage_all            = 'U',
         open_commit_log        = 'h',
         listing_style          = 'L',
         refresh_files          = 'R',
         close                  = 'q',
         option                 = '?',
         toggle_fold            = 'i',
      }

      require('diffview').setup({
         diff_binaries      = false,     -- Show diffs for binaries
         enhanced_diff_hl   = false,     -- See ':h diffview-config-enhanced_diff_hl'
         git_cmd            = { 'git' }, -- The git executable followed by default args.
         use_icons          = true,      -- Requires nvim-web-devicons
         watch_index        = true,      -- Update views and index buffers when the git index changes.
         icons              = {
            -- Only applies when use_icons is true.
            folder_closed = '',
            folder_open   = '',
         },
         signs              = {
            fold_closed = '',
            fold_open   = '',
            done        = '✓',
         },
         view               = {
            -- For more info, see ':h diffview-config-view.x.layout'.
            default = {
               -- Config for changed files, and staged files in diff views.
               layout = 'diff2_horizontal',
            },
            merge_tool = {
               -- Config for conflicted files in diff views during a merge or rebase.
               layout              = 'diff3_horizontal',
               disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
            },
            file_history = {
               -- Config for changed files in file history views.
               layout = 'diff2_horizontal',
            },
         },
         file_panel         = {
            listing_style = 'list', -- One of 'list' or 'tree'
            tree_options  = {
               -- Only applies when listing_style is 'tree'
               flatten_dirs    = true,          -- Flatten dirs that only contain one single dir
               folder_statuses = 'only_folded', -- One of 'never', 'only_folded' or 'always'.
            },
            win_config    = {
               -- See ':h diffview-config-win_config'
               position = 'left',
               width    = 35,
               win_opts = {}
            },
         },
         file_history_panel = {
            log_options = {
               -- See ':h diffview-config-log_options'
               git = {
                  single_file = {
                     diff_merges = 'combined',
                  },
                  multi_file  = {
                     diff_merges = 'first-parent',
                  },
               }
            },
            win_config  = {
               -- See ':h diffview-config-win_config'
               position = 'bottom',
               height   = 16,
               win_opts = {}
            },
         },
         commit_log_panel   = {
            win_config = { -- See ':h diffview-config-win_config'
               win_opts = {},
            }
         },
         default_args       = {
            -- Default args prepended to the arg-list for the listed commands
            DiffviewOpen        = {},
            DiffviewFileHistory = {},
         },
         hooks              = {},    -- See ':h diffview-config-hooks'
         keymaps            = {
            disable_defaults = true, -- Disable the default keymaps
            view = {
               -- The `view` bindings are active in the diff buffers, only when the current
               -- tabpage is a Diffview.
               [keymaps.close]                  = actions.close,                     -- Open the diff for the next file
               [keymaps.select_next_entry]      = actions.select_next_entry,         -- Open the diff for the next file
               [keymaps.select_prev_entry]      = actions.select_prev_entry,         -- Open the diff for the previous file
               [keymaps.toggle_files]           = actions.toggle_files,
               [keymaps.goto_file_tab]          = actions.goto_file_tab,             -- Open the file in a new split in the previous tabpage
               [keymaps.cycle_layout]           = actions.cycle_layout,              -- Cycle through available layouts.
               [keymaps.stage_all]              = actions.stage_all,                 -- Stage all entries.
               [keymaps.unstage_all]            = actions.unstage_all,               -- Unstage all entries.
               [keymaps.listing_style]          = actions.listing_style,             -- Toggle between 'list' and 'tree' views
               [keymaps.refresh_files]          = actions.refresh_files,             -- Update stats and entries in the file list.
               [keymaps.prev_conflict]          = actions.prev_conflict,             -- In the merge_tool: jump to the previous conflict
               [keymaps.next_conflict]          = actions.next_conflict,             -- In the merge_tool: jump to the next conflict
               [keymaps.conflict_choose_ours]   = actions.conflict_choose('ours'),   -- Choose the OURS version of a conflict
               [keymaps.conflict_choose_theirs] = actions.conflict_choose('theirs'), -- Choose the THEIRS version of a conflict
               [keymaps.conflict_choose_base]   = actions.conflict_choose('base'),   -- Choose the BASE version of a conflict
               [keymaps.conflict_choose_all]    = actions.conflict_choose('all'),    -- Choose all the versions of a conflict
               [keymaps.conflict_choose_none]   = actions.conflict_choose('none'),   -- Delete the conflict region
               [keymaps.restore_buf]            = actions.restore_entry,             -- Reset file
               [keymaps.toggle_fold]            = actions.toggle_fold,               -- Reset file
            },
            diff1 = {},
            diff2 = {},
            diff3 = {},
            diff4 = {},
            file_panel = {
               [keymaps.close]              = actions.close,              -- Open the diff for the next file
               [keymaps.goto_file_tab]      = actions.goto_file_tab,      -- Open the file in a new split in the previous tabpage
               [keymaps.select_entry]       = actions.select_entry,       -- Open the diff for the selected entry.
               [keymaps.toggle_stage_entry] = actions.toggle_stage_entry, -- Stage / unstage the selected entry.
               [keymaps.stage_all]          = actions.stage_all,          -- Stage all entries.
               [keymaps.unstage_all]        = actions.unstage_all,        -- Unstage all entries.
               [keymaps.select_next_entry]  = actions.select_next_entry,
               [keymaps.select_prev_entry]  = actions.select_prev_entry,
               [keymaps.listing_style]      = actions.listing_style, -- Toggle between 'list' and 'tree' views
               [keymaps.refresh_files]      = actions.refresh_files, -- Update stats and entries in the file list.
               [keymaps.toggle_files]       = actions.toggle_files,
               [keymaps.cycle_layout]       = actions.cycle_layout,
               [keymaps.prev_conflict]      = actions.prev_conflict, -- In the merge_tool: jump to the previous conflict
               [keymaps.next_conflict]      = actions.next_conflict, -- In the merge_tool: jump to the next conflict
            },
            file_history_panel = {
               [keymaps.close]           = actions.close,   -- Open the diff for the next file
               [keymaps.option]          = actions.options, -- Open the option panel
               [keymaps.open_commit_log] = actions.open_commit_log,
               [keymaps.select_entry]    = actions.select_entry,
               [keymaps.goto_file_tab]   = actions.goto_file_tab,
               [keymaps.toggle_files]    = actions.toggle_files,
               [keymaps.cycle_layout]    = actions.cycle_layout,
            },
            option_panel = {
               -- [keymaps.select_next_entry] = actions.select_entry,
               -- [keymaps.close]             = actions.close,
            },
         },
      })
   end
}
