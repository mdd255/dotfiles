require("config.lazy")

if vim.g.neovide then
  require("config.neovide")
  if vim.fn.has("mac") == 1 then
    require("config.macos")
  end
end

require("config.package_json")
