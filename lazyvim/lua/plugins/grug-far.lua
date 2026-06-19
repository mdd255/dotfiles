return {
  "MagicDuck/grug-far.nvim",
  opts = {
    debounceMs = 400,
    maxSearchMatches = 1000,
    breakindentopt = "shift:1",
    normalModeSearch = false,
    headerMaxWidth = 80,
    showCompactInputs = true,
    astgreg = { placeholders = { enabled = false } },
    engines = {
      placeholders = { enabled = false },
    },
    keymaps = {
      help = { n = "/" },
      previewLocation = { n = "tt" },
      gotoLocation = { n = "<Enter>" },
      historyOpen = { n = "th" },
      historyAdd = { n = "ti" },
      pickHistoryEntry = { n = "<Enter>" },
      nextInput = { n = "<C-Tab>" },
      prevInput = false,
      openNextLocation = { n = "<Tab>" },
      openPrevLocation = { n = "<S-Tab>" },
      syncLine = { n = "to" },
      syncLocations = { n = "ta" },
      abort = { n = "tq" },
      syncFile = { n = "tf" },
      applyNext = { n = "" },
      applyPrev = { n = "" },
      syncNext = { n = "" },
      syncPrev = { n = "" },
      toggleShowCommand = { n = "" },
      swapEngine = { n = "" },
      swapReplacementInterpreter = { n = "" },
    },
  },
  config = function(_, opts)
    require("grug-far").setup(opts)
    local color = require("config.color")
    local ns = vim.api.nvim_create_namespace("grug-far-hl")
    vim.api.nvim_set_hl(ns, "CursorLine", { bg = color.dark_gray })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "grug-far",
      callback = function(ev)
        vim.schedule(function()
          for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
            vim.api.nvim_win_set_option(win, "cursorline", true)
            vim.api.nvim_win_set_hl_ns(win, ns)
          end
        end)
      end,
    })
  end,
  lazy = true,
  keys = {
    { "<Leader>sr", false },
    {
      "fs",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")

        grug.open({
          transient = true,
          prefills = {
            search = "",
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            flags = "-i",
            paths = "",
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
    {
      "S",
      function()
        local grug = require("grug-far")
        local path = vim.bo.buftype == "" and vim.fn.expand("%:.") or ""

        grug.open({
          transient = true,
          prefills = {
            search = "",
            paths = path,
            flags = "-i",
          },
        })
      end,
      mode = "n",
      desc = "Search and Replace (current file)",
    },
  },
}
