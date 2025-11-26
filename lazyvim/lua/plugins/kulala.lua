return {
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "ty", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = "http" },
      { "tp", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = "http" },
      {
        "td",
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = "Download GraphQL schema",
        ft = "http",
      },
      { "th", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request", ft = "http" },
      { "tn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
      { "te", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" },
      { "tt", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
      { "ts", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = "http" },
    },
    opts = {
      custom_dynamic_variables = {
        ["_uuid"] = function()
          local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

          return string.gsub(template, "[xy]", function(c)
            local v = math.random(0, 15)
            if c == "x" then
              return string.format("%x", v)
            else
              v = (v % 4) + 8
              return string.format("%x", v)
            end
          end)
        end,
        ["_email"] = function()
          local domains = { "gmail.com", "yahoo.com", "hotmail.com", "outlook.com" }
          local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
          local length = math.random(5, 10)
          local name = ""

          for i = 1, length do
            local idx = math.random(1, #chars)
            name = name .. chars:sub(idx, idx)
          end

          local domain = domains[math.random(1, #domains)]
          return name .. "@" .. domain
        end,
        ["_phone"] = function()
          local areaCode = math.random(200, 999)
          local prefix = math.random(200, 999)
          local line = math.random(1000, 9999)
          return string.format("(%03d) %03d-%04d", areaCode, prefix, line)
        end,
      },
    },
  },
}
