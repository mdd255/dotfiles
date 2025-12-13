return {
  "MagicDuck/grug-far.nvim",
  opts = {
    normalModeSearch = true,
    headerMaxWidth = 80,
    showCompactInputs = true,
    keymaps = {
      openNextLocation = { n = "tn" },
      openPrevLocation = { n = "te" },
      syncLocations = { n = "ta" },
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
            search = vim.fn.expand("<cword>"),
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            flags = "-i",
            paths = vim.fn.expand("%:."),
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
  },
}
