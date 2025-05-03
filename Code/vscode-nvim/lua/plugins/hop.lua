return {
   'smoka7/hop.nvim',
   config = function()
      local hop = require('hop')
      local vscode = vim.g.vscode and require('vscode')

      if vim.g.vscode then vscode = require('vscode') end
      local directions = require('hop.hint').HintDirection
      local map = require('base.utils').map

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

      ---@param forward? boolean
      local function hop_word(forward)
         local direction = forward and directions.AFTER_CURSOR or directions.BEFORE_CURSOR

         return function()
            if vscode then
               vscode.update_config('editor.occurrencesHighlight', 'off', 'global')
            end
            hop.hint_words({
               multi_windows = false,
               direction = direction
            })
            if vscode then
               vscode.update_config('editor.occurrencesHighlight', 'singleFile', 'global')
            end
         end
      end

      map('n', 'cn', function() hop_modify('ci') end)
      map('n', 'dn', function() hop_modify('di', true) end)
      map('n', 'yn', function() hop_modify('yi', true) end)
      map('n', 'zn', function() hop_modify('vi') end)

      map('n', 'ce', function() hop_modify('ca') end)
      map('n', 'de', function() hop_modify('da', true) end)
      map('n', 'ye', function() hop_modify('ya', true) end)
      map('n', 'ze', function() hop_modify('va') end)

      map('n', 'w', hop_word(true))
      map('n', 'b', hop_word(false))
   end
}
