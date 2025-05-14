-- stylua: ignore
local color = {
   black     = '#0a0a0a',
   cyan      = '#2bbac5',
   yellow    = '#e5c07b',
   orange    = '#d19a66',
   white     = '#eeeeee',
   purple    = '#d38aea',
   blue      = '#61afef',
   red       = '#ef596f',
   light_red = '#00ffff',
   green     = '#89ca78',
   gray      = '#777777',
}

return {
  {
    "olimorris/onedarkpro.nvim",
    config = function()
      require("onedarkpro").setup({
        colors = {
          gray = color.gray,
          blue = color.blue,
          cyan = color.cyan,
          black = color.black,
          orange = color.orange,
          white = color.white,
          purple = color.purple,
          yellow = color.yellow,
          red = color.red,
          light_red = color.light_red,
          green = color.green,
          float_bg = color.black,
          bg_statusline = color.black,
          bg = color.black,
          comment = color.gray,
          git_add = color.green,
          git_change = color.orange,
          git_delete = color.red,
          git_hunk_add = color.green,
          git_hunk_delete = color.red,
          diff_delete = color.red,
          highlight = color.orange,
          git_hunk_delete_inline = color.red,
          virtual_text_hint = color.cyan,
          virtual_text_error = color.red,
          diff_text = color.green,
          virtual_text_warning = color.yellow,
          virtual_text_information = color.blue,
          cursorline = "#303030",
          selection = "#2e2e2e",
          color_column = "#232323",
          fold = "#1f1f1f",
          git_hunk_add_inline = "#3f534f",
          diff_add = "#003e4a",
          fg_gutter_inactive = "#abb2bf",
          fg = "#abb2bf",
          git_hunk_change_inline = "#41483d",
          line_number = "#495162",
          inlay_hint = "#33373e",
          indentline = "#2c2c2c",
          fg_gutter = "#252525",
        },
        highlights = {
          ["@punctuation.delimiter"] = { fg = "${yellow}" },
          ["@punctuation.special"] = { fg = "${blue}" },
          ["@punctuation.bracket"] = { fg = "${yellow}" },
          ["@operator"] = { fg = "${yellow}" },
          NvimTreeCursorLine = { bg = "${cursorline}" },
          DiffviewDiffDelete = { bg = "${light_red}" },
          Visual = { bg = "${blue}", fg = "${black}" },
          NvimTreeFolderIcon = { fg = "${comment}" },
          NvimTreeFolderName = { fg = "${comment}" },
          NvimTreeOpenedFolderName = { fg = "${blue}" },
          NvimTreeOpenedFolderIcon = { fg = "${blue}" },
          GitSignsCurrentLineBlame = { bg = "${cursorline}", fg = "${comment}" },
          CursorLineNr = { fg = "${blue}" },
          CocErrorHighlight = { underline = true, fg = "${red}" },
          CocWarningHighlight = { underline = true, fg = "${yellow}" },
          CocHintHighlight = { underline = true, fg = "${blue}" },
          TelescopeMatching = { fg = "${blue}" },
          TelescopeSelectionCaret = { fg = "${blue}", bg = "${cursorline}" },
          TelescopeSelection = { fg = "${white}", bg = "${cursorline}" },
          IblWhitespace = { fg = "${cursorline}" },
          HopNextKey = { bg = "${white}", fg = "${black}" },
          HopNextKey1 = { bg = "${white}", fg = "${black}" },
        },
        options = {
          cursorline = true, -- Use cursorline highlighting?
          transparency = false, -- Use a transparent background?
          terminal_colors = true, -- Use the theme's colors for Neovim's :terminal?
          lualine_transparency = false, -- Center bar transparency?
          highlight_inactive_windows = false, -- When the window is out of focus, change the normal background?
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark_dark",
    },
  },
}
