---@diagnostic disable: undefined-global
local map = require("config.utils").map
local gh_actions = require("config.gh-actions-functions")

map({
  {
    "<Leader>gA",
    gh_actions.gh_actions_picker,
    { modes = { "n" }, desc = "GH Actions picker" },
  },
})
