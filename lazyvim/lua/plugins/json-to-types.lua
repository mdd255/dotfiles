return {
  "Redoxahmii/json-to-types.nvim",
  build = "sh install.sh npm",
  ft = "json",
  keys = {
    {
      "ct",
      "<CMD>ConvertJSONtoLang typescript<CR>",
      desc = "Convert JSON to TS",
    },
    {
      "cg",
      "<CMD>ConvertJSONtoLang go<CR>",
      desc = "Convert JSON to Go",
    },
  },
}
