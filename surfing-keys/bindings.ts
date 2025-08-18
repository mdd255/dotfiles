import { Bindings } from './types.d';

const customBindings: Partial<Record<keyof typeof Bindings, string>> = {
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
  copy_current_url: 'yy',
};

export function buildBindings(): void {
	for (const [key, customBindKey] of Object.entries(customBindings)) {
    const defaultBindKey = Bindings[key as keyof typeof Bindings]
    api.map(customBindKey, defaultBindKey)
	}
};