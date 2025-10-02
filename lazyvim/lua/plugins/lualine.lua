local color = require("config/color")

local theme = {
  visual = {
    a = { bg = color.black, fg = color.red },
    b = { bg = color.black, fg = color.red },
    c = { bg = color.black, fg = color.red },
  },
  inactive = {
    a = { fg = color.gray, bg = color.black },
    b = { fg = color.gray, bg = color.black },
    c = { fg = color.gray, bg = color.black },
  },
  insert = {
    a = { bg = color.black, fg = color.purple },
    b = { bg = color.black, fg = color.purple },
    c = { bg = color.black, fg = color.purple },

    x = { bg = color.black, fg = color.purple },
    y = { bg = color.black, fg = color.purple },
    z = { bg = color.black, fg = color.purple },
  },
  normal = {
    a = { bg = color.black, fg = color.blue },
    b = { bg = color.black, fg = color.blue },
    c = { bg = color.black, fg = color.blue },
  },
  replace = {
    a = { bg = color.black, fg = color.orange },
    b = { bg = color.black, fg = color.orange },
    c = { bg = color.black, fg = color.orange },
  },
  terminal = {
    a = { bg = color.black, fg = color.cyan },
    b = { bg = color.black, fg = color.cyan },
    c = { bg = color.black, fg = color.cyan },
  },
}

local shorten_filename = function(str)
  local found_current_idx = str:find("%.", 1)

  if found_current_idx == nil or found_current_idx == 1 then
    return str
  end

  local last_found_idx = found_current_idx

  while found_current_idx ~= nil do
    last_found_idx = found_current_idx
    found_current_idx = str:find("%.", last_found_idx + 1)
  end

  return str:sub(1, last_found_idx - 1)
end

local file_name = {
  "filename",
  file_status = true,
  path = 1,
  shorting_target = 50,
}

local tabs = {
  "tabs",
  mode = 1,
  fmt = shorten_filename,
}

local mode = {
  "mode",
  icons_enabled = true,
  icon = "",
  fmt = function(str)
    return str:sub(1, 3)
  end,
}

local diff = {
  "diff",
  colored = false,
  symbols = { added = " ", modified = " ", removed = " " },
}

local branch = {
  "branch",
  icon = "",
  fmt = function(str)
    if str:len() > 80 then
      return str:sub(1, 77) .. "..."
    end

    return str
  end,
}

local diagnostics = {
  "diagnostics",
  colored = false,
}

local searchcount = {
  "searchcount",
}

local windows = {
  "windows",
  show_filename_only = true,
  show_modified_status = true,
  mode = 0,
  fmt = shorten_filename,
  disabled_buftypes = { "terminal", "nofile", "" },
}

local project_name = [[vim.fn.getcwd():gsub("^.*/", "")]]

return {
  "nvim-lualine/lualine.nvim",
  config = function()
    local _recorder = require("recorder")

    require("lualine").setup({
      disabled_filetypes = {
        statusline = {},
      },
      sections = {
        lualine_a = {},
        lualine_b = { mode },
        lualine_c = { file_name, diagnostics },
        lualine_x = { searchcount, _recorder.recordingStatus, _recorder.displaySlots },
        lualine_y = { diff, "location", "progress", project_name, branch },
        lualine_z = {},
      },
      tabline = {
        lualine_a = { windows },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = { tabs },
        lualine_z = {},
      },
      winbar = {},
      extensions = {},
      options = {
        icons_enabled = true,
        theme = theme,
        component_separators = { left = "󰇝", right = "󰇝" },
        section_separators = { left = "", right = "" },
        always_divide_middle = true,
        disabled_filetypes = { "dbui", "dbout", "snacks_terminal", "snacks_dashboard", "copilot-chat" },
      },
    })
  end,
}
