return {
  "ywsrock/nvim-md-preview",
  build = ":MdPreviewInstall",
  config = function()
    require("md_preview").setup({})
  end,
}
