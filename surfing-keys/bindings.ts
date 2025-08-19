import { Bindings } from './types.d';

const passThroughBindings: (keyof typeof Bindings)[] = [
  'show_usage',
  'open_link',
  'scroll_to_top',
  'scroll_to_bottom',
  'reload_page',
  'copy_current_url',
  'find_current_page',
  'toggle_visual_mode',
]

const customBindings: Partial<Record<keyof typeof Bindings, string>> = {
  choose_tab: '<Space>',
  next_found_text: 'm',
  previous_found_text: 'M',
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
  open_url: '<Enter>',
};

export function buildBindings(): void {
  const enabledKeys: string[] = [];

  for (const key of passThroughBindings) {
    const bindKey = Bindings[key];
    enabledKeys.push(bindKey);
  }

	for (const [key, customBindKey] of Object.entries(customBindings)) {
    const defaultBindKey = Bindings[key as keyof typeof Bindings]
    api.unmap(customBindKey)
    api.map(customBindKey, defaultBindKey)
    enabledKeys.push(customBindKey);
    api.unmap(defaultBindKey)
	}
  api.unmapAllExcept(enabledKeys, /.+/);
};