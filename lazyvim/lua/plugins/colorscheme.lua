local color = require("config/color")

local hi = {
  black = "${black}",
  cyan = "${cyan}",
  yellow = "${yellow}",
  orange = "${orange}",
  white = "${white}",
  purple = "${purple}",
  blue = "${blue}",
  red = "${red}",
  light_red = "${light_red}",
  green = "${green}",
  gray = "${gray}",
  dark_gray = "${dark_gray}",
  cursorline = "${cursorline}",
  comment = "${comment}",
  light_blue = "${light_blue}",
}

return {
  {
    "olimorris/onedarkpro.nvim",
    config = function()
      require("onedarkpro").setup({
        colors = {
          dark_gray = color.dark_gray,
          light_blue = color.light_blue,
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
          cursorline = color.black,
          selection = color.dark_gray,
          color_column = color.dark_gray,
          fold = color.dark_gray,
          git_hunk_add_inline = color.gray,
          diff_add = color.cyan,
          fg_gutter_inactive = color.white,
          fg = color.white,
          git_hunk_change_inline = color.gray,
          line_number = color.gray,
          inlay_hint = color.dark_gray,
          indentline = color.gray,
          fg_gutter = color.gray,
        },
        highlights = {
          -- Treesitter
          ["@punctuation.delimiter"] = { fg = hi.yellow },
          ["@punctuation.special"] = { fg = hi.blue },
          ["@punctuation.bracket"] = { fg = hi.yellow },
          ["@operator"] = { fg = hi.yellow },
          ["@lsp.type.function.typescript"] = { fg = hi.purple },
          ["@type.property.typescript"] = { fg = hi.light_blue },
          ["@lsp.type.class"] = { fg = hi.blue },
          ["@boolean"] = { fg = hi.purple },
          ["@variable.member"] = { fg = hi.orange },

          -- Vim
          Type = { fg = hi.blue },
          DiagnosticUnderlineError = { underline = true },
          DiagnosticUnderlineInfo = { underline = true },
          DiagnosticUnderlineWarn = { underline = true },
          DiagnosticUnderlineHint = { underline = true },
          SpellBad = { underline = true },
          SpellCap = { underline = true },
          SpellRare = { underline = true },
          SpellLocal = { underline = true },
          Visual = { bg = hi.blue, fg = hi.black },
          CursorLineNr = { fg = hi.black, bold = true, bg = hi.gray },
          CursorColumn = { bg = hi.dark_gray },
          IblWhitespace = { fg = hi.dark_gray },
          WinSeparator = { fg = hi.blue },

          -- gitsign & diffview
          GitSignsCurrentLineBlame = { bg = hi.cursorline, fg = hi.comment },
          DiffviewDiffDelete = { bg = hi.light_red },

          -- flash.nvim
          FlashLabel = { fg = hi.blue, bg = hi.black },
          FlashMatch = { fg = hi.gray, bg = hi.black },
          FlashCurrent = { fg = hi.red, bg = hi.black, underline = true },
          FlashBackdrop = { fg = hi.gray, bg = hi.black },

          -- snacks
          SnacksIndent = { fg = hi.gray },
          SnacksIndentScope = { fg = hi.white },
          SnacksPickerPrompt = { bg = hi.black, fg = hi.white },
          SnacksPickerListCursorLine = { bg = hi.dark_gray },
          SnacksPickerList = { fg = hi.gray },
          SnacksDashboardHeader = { fg = hi.blue },

          -- grugfar
          GrugFarResultsMatch = { bg = hi.gray, fg = hi.blue },
          GrugFarResultsPath = { fg = hi.red, underline = true, italic = true },
        },
        options = {
          cursorline = false,
          transparency = false,
          terminal_colors = true,
          lualine_transparency = true,
          highlight_inactive_windows = false,
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    keys = false,
    opts = {
      colorscheme = "onedark_dark",
    },
  },
}
