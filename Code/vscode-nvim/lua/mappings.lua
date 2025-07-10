local utils = require('base.utils')
local map = utils.map
local action = utils.vscodeAction
local whichKey = utils.which_key

-- avoid visual paste overwrite register
map('vx', 'p', '"_dP')

-- colemak bindings
map('nv', 'k', 'i')
map('nv', 'K', 'I')
map('nv', 'n', 'j')
map('nv', 'e', 'k')
map('nv', 'i', 'l')

-- tabs cmds
map('n', 'N', action('workbench.action.previousEditorInGroup'))
map('n', 'E', action('workbench.action.nextEditorInGroup'))

-- file explorer
map('n', '-', action('workbench.view.explorer'))

-- scroll cmds
map('nv', 'm', '<C-d>')
map('nv', 'M', '<C-u>')

-- whichkey
map('n', 's', whichKey('s'))
map('nvo', 'f', whichKey('f'))
map('n', 'g', whichKey('g'))
map('n', 't', whichKey('t'))
map('n', 'z', whichKey('z'))
map('n', '_', whichKey('w'))

-- window navs
map('n', '<Space>i', action('workbench.action.navigateRight'))
map('n', '<Space>h', action('workbench.action.navigateLeft'))
map('n', '<Space>e', action('workbench.action.navigateUp'))
map('n', '<Space>n', action('workbench.action.navigateDown'))

-- misc
map('n', '<Cr>', action('workbench.action.showCommands'))
map('n', '/', action('actions.find'))
map('n', '<Space>q', action('workbench.action.closeActiveEditor'))
map('n', '<Space>Q', action('workbench.action.closeOtherEditors'))
map('n', 'U', '<C-r>')
map('nv', ';', action('editor.action.commentLine', 'n'))

-- custom select cmds
map('n', '<Space>v', 'V')
map('n', 'V', 'v$h')

-- toggle upper/lower/camel case
map('v', 'u', 'U')
map('v', 'l', 'u')

-- mru file nav cmds
map('n', 'I', action('workbench.action.navigateForward'))
map('n', 'H', action('workbench.action.navigateBack'))

-- extensions
map('n', '<Space>d', action('github.cweijan.mysql.focus'))
