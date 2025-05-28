return {
   'smoka7/hop.nvim',
   config = function()
      local hop    = require('hop')
      local utils  = require('base.utils')
      local color  = utils.color
      local hi     = utils.hi
      local vscode = vim.g.vscode and require('vscode')
      local map    = utils.map

      hop.setup({
         multi_windows    = true,
         uppercase_labels = false,
         keys             = 'neio\'arstdhqwfpluy;zxcvbkm,.',
      })

      ---@param brackets table
      ---@return string
      local function pair_regex(brackets)
         local result = ''

         for _, bracket in pairs(brackets) do
            local open = bracket[1]

            if #bracket == 2 then
               result = #result > 0 and result .. '\\|' .. open or open
               goto continue
            end

            local close = #bracket > 1 and bracket[2] or open
            local multi_line_match = open .. '$'
            local one_line_match = open .. '[^' .. close .. ']*' .. close
            local match = multi_line_match .. '\\|' .. one_line_match
            result = #result > 0 and result .. '\\|' .. match or match
            ::continue::
         end

         return result
      end

      local regex = pair_regex({
         { '(',   ')' },
         { '\\[', ']' },
         { '<',   '>' },
         { '{',   '}' },
         { '`' },
         { '\'' },
         { '"' },
      })

      local function hint_pairs()
         return hop.hint_patterns(
            {
               current_line_only = false
            },
            regex
         )
      end

      ---@param action string
      ---@param preserve_pos? boolean
      ---@return nil
      local function hop_modify(action, preserve_pos)
         preserve_pos = preserve_pos or false
         local old_pos = vim.api.nvim_win_get_cursor(0)
         local current_line = vim.api.nvim_get_current_line()
         local current_idx = vim.api.nvim_win_get_cursor(0)[2] + 1
         local current_char = current_line:sub(current_idx, current_idx)

         if vscode then
            vscode.update_config('editor.occurrencesHighlight', 'off', 'global')
         end
         -- auto apply action on open brackets
         local keys = { '(', '[', '{', '<', '\'', '"' }
         for _, key in pairs(keys) do
            if current_char == key then
               local _cmd = 'normal ' .. action .. current_char
               vim.cmd(_cmd)

               if startinsert then
                  vim.cmd('startinsert')
               end

               if vscode then
                  vscode.update_config('editor.occurrencesHighlight', 'singleFile', 'global')
               end
               return
            end
         end
         if pcall(hint_pairs) then
            local new_pos = vim.api.nvim_win_get_cursor(0)
            current_line = vim.api.nvim_get_current_line()
            current_idx = vim.api.nvim_win_get_cursor(0)[2] + 1
            current_char = current_line:sub(current_idx, current_idx)
            local _cmd = action .. current_char

            if vim.deep_equal(old_pos, new_pos) == false then
               vim.api.nvim_feedkeys(_cmd, 'n', false)

               if preserve_pos then
                  vim.defer_fn(function()
                     vim.api.nvim_win_set_cursor(0, old_pos)
                  end, 50)
               end
            end
            if vscode then
               vscode.update_config('editor.occurrencesHighlight', 'singleFile', 'global')
            end
         end
      end

      -- highlight groups
      hi('HopNextKey', { fg = color.red })
      hi('HopNextKey1', { fg = color.red })
      hi('HopNextKey2', { fg = color.blue })

      -- keymaps
      -- map('n', 'cn', function() hop_modify('ci') end)
      -- map('n', 'dn', function() hop_modify('di', true) end)
      -- map('n', 'yn', function() hop_modify('yi', true) end)
      -- map('n', 'zn', function() hop_modify('vi') end)
      --
      -- map('n', 'ce', function() hop_modify('ca') end)
      -- map('n', 'de', function() hop_modify('da', true) end)
      -- map('n', 'ye', function() hop_modify('ya', true) end)
      -- map('n', 'ze', function() hop_modify('va') end)
   end
}
