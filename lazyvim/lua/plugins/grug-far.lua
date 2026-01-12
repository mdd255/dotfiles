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
      openNextLocation = { n = "tn" },
      openPrevLocation = { n = "te" },
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
  cmd = "GrugFar",
  keys = {
    { "<Leader>sr", false },
    {
      "S",
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
  },
}
