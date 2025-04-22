return {
   'phaazon/hop.nvim',
   config = function()
      local hop = require('hop')
      local map = require('base.utils').map

      hop.setup({
         multi_windows    = true,
         uppercase_labels = true,
         keys             = 'arstdhneioqwfpluy;zxcvkm,.',
      })

      local function hint_pairs()
         return hop.hint_patterns(
            {
               current_line_only = true
            },
            '(\\|\\[\\|{\\|<\\|\'\\|"\\|`'
         )
      end

      local function custom_actions(action, startinsert)
         local current_line = vim.api.nvim_get_current_line()
         local current_index = vim.api.nvim_win_get_cursor(0)[2] + 1
         local current_char = current_line:sub(current_index, current_index)
         local keys = { '(', '[', '{', '<', '\'', '"' }

         for _, key in pairs(keys) do
            if current_char == key then
               local _cmd = 'normal ' .. action .. current_char
               vim.cmd(_cmd)

               if startinsert then
                  vim.cmd('startinsert')
               end

               return
            end
         end

         if pcall(hint_pairs) then
            current_index = vim.api.nvim_win_get_cursor(0)[2] + 1
            current_char = current_line:sub(current_index, current_index)
            local _cmd = 'normal ' .. action .. current_char
            vim.cmd(_cmd)

            if startinsert then
               vim.cmd('startinsert')
            end
         end
      end

      map('n', 'cn', function() custom_actions('di', true) end)
      map('n', 'dn', function() custom_actions('di') end)
      map('n', 'yn', function() custom_actions('yi') end)
      map('n', 'vn', function() custom_actions('vk') end)

      map('n', 'ce', function() custom_actions('da', true) end)
      map('n', 'de', function() custom_actions('da') end)
      map('n', 'ye', function() custom_actions('ya') end)
      map('n', 've', function() custom_actions('va') end)
   end
}
