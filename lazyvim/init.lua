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

require("config.package_json")
