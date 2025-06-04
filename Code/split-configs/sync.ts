import { joinConfigs } from './join-configs'

const basePath = `${process.env.HOME}/.config/dotfiles/Code/User`

joinConfigs({
  keybindingsPartialPath: `${basePath}/partials/keybindings/`,
  keybindingsPath: `${basePath}/keybindings.json`,
  settingsPartialPath: `${basePath}/partials/settings/`,
  settingsPath: `${basePath}/settings.json`,
  excludedFilenames: ['macos_remove.json', 'macos_bind.json'],
})
