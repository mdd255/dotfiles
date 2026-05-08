return {
  "Redoxahmii/json-to-types.nvim",
  build = "sh install.sh npm",
  ft = "json",
  keys = {
    {
      "tt",
      "<CMD>ConvertJSONtoLang typescript<CR>",
      desc = "Convert JSON to TS",
    },
    {
      "tg",
      "<CMD>ConvertJSONtoLang go<CR>",
      desc = "Convert JSON to Go",
    },
  },
}
