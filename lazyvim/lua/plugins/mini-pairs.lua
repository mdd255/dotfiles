return {
  "echasnovski/mini.pairs",
  opts = {
    modes = { insert = true, command = false, terminal = false },

    -- Global mappings. Each right hand side should be a pair information, a
    -- table with at least these fields (see more in |MiniPairs.map|):
    -- - <action> - one of 'open', 'close', 'closeopen'.
    -- - <pair> - two character string for pair to be used.
    -- By default pair is not inserted after `\`, quotes are not recognized by
    -- <CR>, `'` does not insert pair after a letter.
    -- Only parts of tables can be tweaked (others will use these defaults).
    --
    mappings = {
      ["<c-n>"] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
      ["<c-e>"] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
      ["<c-i>"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },

      ["<c-o>"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\].", register = { cr = false } },
      ["<c-a>"] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
      ["<c-r>"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
    },
  },
}
