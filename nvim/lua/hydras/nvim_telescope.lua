local hydra       = require('hydras._hydra')
local tls_builtin = require('telescope.builtin')
local telescope   = require('telescope')
local cmd         = require('hydra.keymap-util').cmd

local function lsp_functions()
   tls_builtin.treesitter({ symbols = 'function', show_line = false })
end

local function live_grep()
   tls_builtin.live_grep({ max_results = 40, disable_coordinates = true })
end

local function oldfiles()
   tls_builtin.oldfiles({ cwd_only = true })
end

local keymap = {
   body  = 'f',
   heads = {
      ['Recent files']            = { key = 'f', fn = oldfiles },
      ['Git commit']              = { key = '<tab>', fn = tls_builtin.git_commits },
      ['Git commit current file'] = { key = '<cr>', fn = tls_builtin.git_bcommits },
      ['Find files']              = { key = 'a', fn = tls_builtin.find_files },
      ['Buffers']                 = { key = 'b', fn = tls_builtin.buffers },
      ['Project search']          = { key = 's', fn = live_grep },
      ['LSP function']            = { key = 'o', fn = lsp_functions },
      ['LSP type definition']     = { key = 't', fn = tls_builtin.lsp_type_definitions },
      ['Key mappings']            = { key = 'm', fn = tls_builtin.keymaps },
      ['Highlights']              = { key = 'h', fn = tls_builtin.highlights },
      ['Git branches']            = { key = 'g', fn = tls_builtin.git_branches },
      ['Git conflicts']           = { key = 'c', fn = cmd 'Telescope conflicts' },
      ['Git status']              = { key = 'u', fn = cmd 'Telescope git_status' },
      ['Projects']                = { key = 'p', fn = telescope.extensions.project.project },
      ['Pull requests']           = { key = '/', fn = telescope.extensions.gh.pull_request },
      ['MRU telescope cmd']       = { key = '<space>', fn = tls_builtin.resume },
   }
}

hydra.create({
   name   = 'Telescope',
   keymap = keymap,
   conf   = {
      position = 'middle'
   }
})
