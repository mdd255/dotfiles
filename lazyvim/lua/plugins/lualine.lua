local color = require("config/color")

local theme = {
  normal = {
    a = { bg = color.black, fg = color.blue },
    b = { bg = color.black, fg = color.blue },
    c = { bg = color.black, fg = color.blue },
  },
}

local trim_ft = function(full_filename)
  local filename = full_filename:match("^(.*)%.")

  if not filename then
    return full_filename
  end

  return filename
end

local shorten_filename = function(full_filename)
  if full_filename:sub(1, 1) == "." then
    return full_filename
  end

  local filename = trim_ft(full_filename)

  if filename:len() > 15 then
    return filename:sub(1, 15) .. "_"
  end

  return filename
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
  icon = "󱀤",
}

local diff = {
  "diff",
  colored = false,
  symbols = { added = " ", modified = " ", removed = " " },
}

local branch = {
  "branch",
  icon = "",
  fmt = function(str)
    if str:len() > 80 then
      return str:sub(1, 77) .. "_"
    end

    return str
  end,
}

local diagnostics = {
  "diagnostics",
  colored = false,
}

local windows = {
  "windows",
  show_filename_only = true,
  show_modified_status = true,
  mode = 0,
  fmt = trim_ft,
  disabled_buftypes = { "terminal", "nofile", "" },
}

local lsp_status = {
  "lsp_status",
  icon = "󰙴 ",
}

local project_name = function()
  local cwd = vim.loop.cwd()
  return " " .. string.gsub(cwd, "^.*/", "")
end

return {
  "nvim-lualine/lualine.nvim",
  config = function()
    local recorder = require("recorder")

    require("lualine").setup({
      disabled_filetypes = {
        statusline = {},
      },
      sections = {
        lualine_a = {},
        lualine_b = { mode },
        lualine_c = { file_name, diagnostics },
        lualine_x = { "searchcount", recorder.recordingStatus, recorder.displaySlots },
        lualine_y = { diff, "location", "progress", project_name, branch },
        lualine_z = {},
      },
      tabline = {
        lualine_a = { windows, lsp_status },
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
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        always_divide_middle = true,
        disabled_filetypes = {
          "dbui",
          "dbout",
          "snacks_terminal",
          "snacks_dashboard",
          "opencode_terminal",
        },
      },
    })
  end,
}
