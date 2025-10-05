local DEFAULT_LABEL_CHARS = "abcdefghijklmnopqrstuvwxyz0123456789"

-- helper: normalize the key returned by on_key()
local function key_to_str(key)
  -- convert termcodes/raw bytes into a readable key (e.g. "a", "<Esc>", etc)
  return vim.api.nvim_replace_termcodes(key, true, true, true)
end

-- Wrapper that starts flash and will exit it if user presses a non-label key,
-- then re-feed that key so normal vim behavior happens.
local function jump_with_fallback(opts)
  opts = opts or {}

  -- build label-char lookup (fast check)
  local labels = {}
  for i = 1, #DEFAULT_LABEL_CHARS do
    labels[DEFAULT_LABEL_CHARS:sub(i, i)] = true
  end

  local unregister -- will hold the on_key unregistration function
  local active = true

  -- on_key callback: intercept the very next key(s)
  unregister = vim.on_key(function(key)
    if not active then
      return
    end

    local k = key_to_str(key)
    -- treat multi-char termcodes (like <Esc>, <CR>) as "not a small single label"
    local is_single_char = #k == 1

    -- If it's not a single printable label or not in our label set, treat it as fallback:
    if not (is_single_char and labels[k]) then
      active = false
      -- unregister so we don't capture the key we re-feed
      if unregister then
        unregister()
      end
      -- send <Esc> to close flash overlay
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      -- re-feed the original raw key so normal vim will handle it
      -- feed as "m" (means replace typed keys) — use 'n' or '' depending on behavior you want
      vim.api.nvim_feedkeys(key, "n", false)
    end
    -- if it is a valid label (single char found in labels), do nothing: let flash handle it
  end, nil)

  -- call flash.jump (blocking until user selects, or we cancel it via feeding <Esc>)
  -- keep remote_op true if using operator-pending mode, pass whichever opts you need
  require("flash").jump(opts)

  -- cleanup (in case flash returned naturally)
  active = false
  if unregister then
    unregister()
  end
end

return {
  "folke/flash.nvim",
  opts = {
    exclude = { "snacks_dashboard" },
    jump = { autojump = false },
    labels = "neioharstqfpluyzxkmgj;-NEIOHARSTQFLUYZXVKMBGJ;",
    modes = {
      char = {
        keys = {},
      },
    },
    label = {
      uppercase = false,
      current = true,
      before = false,
      after = true,
    },
    search = {
      multi_window = false,
    },
  },
  keys = function()
    return {
      {
        "w",
        mode = { "n" },
        function()
          -- require("flash").jump({
          jump_with_fallback({
            search = {
              mode = "search",
              max_length = 0,
              wrap = false,
              forward = true,
              multi_windows = false,
            },
            pattern = [[\<]],
          })
        end,
        desc = "Flash forward to beginning of word",
      },
      {
        "b",
        mode = { "n" },
        function()
          require("flash").jump({
            search = {
              mode = "search",
              max_length = 0,
              multi_windows = false,
              wrap = false,
              forward = false,
            },
            pattern = [[\<]],
          })
        end,
        desc = "Flash backward to beginning of word",
      },
    }
  end,
}
