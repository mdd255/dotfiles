import { Bindings } from './types.d'

const passThroughBindings: PassThroughBindings = {
  Normal: [
    'show_usage',
    'open_link',
    'scroll_to_top',
    'scroll_to_bottom',
    'reload_page',
    'copy_current_url',
    'open_bookmark',
  ],
  Visual: ['find_current_page', 'toggle_visual_mode'],
}

const customBindings: CustomBindings = {
  Normal: {
    display_hints_scrollable: 'w',
    scroll_half_page_up: 'e',
    scroll_half_page_down: 'n',
    // scroll_right: 'i',
    go_edit_box: 'o',
    go_edit_box_vim: 'O',
    move_tab_left: '<',
    move_tab_right: '>',
    go_back_history: 'H',
    go_forward_history: 'I',
    close_current_tab: 'q',
    duplicate_current_tab: 'd',
    copy_link_url: 'yf',
    yank_text_element: 'yt',
    open_url: 'l',
    choose_tab: 't',
    edit_url_vim_reload: 'a',
    edit_url_vim_new: 'A',
    go_one_tab_left: 'N',
    go_one_tab_right: 'E',
  },
  Visual: {
    next_found_text: 'm',
    previous_found_text: 'M',
    forward_line: 'n',
    backward_line: 'e',
    forward_character: 'i',
  },
  Insert: {
    exit_insert_mode: '<Esc>',
  },
}

function remap(mode: Mode, customBindings: CustomBindings): string[] {
  let mapFn: typeof api.map
  let unmapFn: typeof api.unmap

  switch (mode) {
    case 'Insert':
      mapFn = api.imap
      unmapFn = api.iunmap
      break

    case 'Visual':
      mapFn = api.vmap
      unmapFn = api.vunmap
      break

    case 'Command':
      mapFn = api.cmap
      unmapFn = api.unmap
      break

    default:
      mapFn = api.map
      unmapFn = api.unmap
  }

  const modePassThroughKeys: string[] = passThroughBindings[mode] || []
  const modeBindings = Bindings[mode] || {}
  const excludeKeys: string[] = modePassThroughKeys.map(
    (key) => modeBindings[key as keyof typeof modeBindings],
  )
  const modeCustomBindings = customBindings[mode] || {}

  for (const [key, customBindKey] of Object.entries(modeCustomBindings)) {
    const defaultBindKey = modeBindings[key as keyof typeof modeBindings]

    mapFn(customBindKey, defaultBindKey)
    excludeKeys.push(customBindKey)
    unmapFn(defaultBindKey)
  }

  return excludeKeys
}

export function buildBindings(): void {
  const excludedKeys: string[] = []

  for (const mode in customBindings) {
    const excludedChunk = remap(mode as Mode, customBindings)
    excludedKeys.push(...excludedChunk)
  }

  api.unmapAllExcept(excludedKeys)

  // Ace Vim bindings
  api.aceVimMap('n', 'j')
  api.aceVimMap('e', 'k')
  api.aceVimMap('i', 'l')
}
// api.unmapAllExcept(['?', 'r'])
api.vunmap('0')
api.vunmap('l')
api.vunmap('h')
api.vunmap('j')
