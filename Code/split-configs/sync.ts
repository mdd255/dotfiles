import { joinConfigs } from './join-configs'

const basePath = '/Users/dungtd4/.config/dotfiles/Code/User'

joinConfigs({
  keybindingsPartialPath: `${basePath}/partials/keybindings/`,
  keybindingsPath: `${basePath}/keybindings.json`,
  settingsPartialPath: `${basePath}/partials/settings/`,
  settingsPath: `${basePath}/settings.json`,
  excludedFilenames: ['linux_remove.json'],
})
