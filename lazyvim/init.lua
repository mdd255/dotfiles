require("config.lazy")

if vim.g.neovide then
  require("config.neovide")
  if vim.fn.has("mac") == 1 then
    require("config.macos")
  end
end

if vim.fn.has("linux") == 1 then
  require("config.linux")
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("PkgJsonLazyLoad", { clear = true }),
  pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact", "json" },
  once = true,
  callback = function(ev)
    require("config.package_json")
    vim.api.nvim_exec_autocmds("FileType", { group = "PkgJsonKeymaps", buffer = ev.buf })
  end,
})
