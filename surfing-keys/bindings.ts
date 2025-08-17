const CustomBindings: Partial<Record<keyof typeof Bindings, string>> = {
	scroll_page_down: 'j',
	show_help: '?',
	choose_tab: 'T',
};

const Bindings = {
  // Navigation
  scroll_down: 'j',
  scroll_up: 'k',
  scroll_left: 'h',
  scroll_right: 'l',
  scroll_page_down: 'd',
  scroll_page_up: 'u',
  scroll_full_page_down: 'ctrl+f',
  scroll_full_page_up: 'ctrl+b',
  scroll_to_bottom: 'G',
  scroll_to_top: 'gg',
  scroll_element_left: 'shift+h',
  scroll_element_right: 'shift+l',

  // Hints
  follow_link_new_tab: 'f',
  follow_link_current_tab: 'F',
  follow_link_non_active_new_tab: 'ctrl+f',
  follow_link_new_window: 'ctrl+shift+f',
  open_multiple_links: 'mf',
  yank_text_of_link: 'yf',
  copy_link_url: 'ya',
  follow_input: 'i',
  follow_onclick: 'O',

  // Tabs
  close_current_tab: 'x',
  restore_closed_tab: 'X',
  next_tab: 'E',
  previous_tab: 'R',
  first_tab: 'g0',
  last_tab: 'g$',
  move_tab_left: '<<',
  move_tab_right: '>>',
  choose_tab: 'T',
  go_to_tab: 'gt',
  close_tab_right: 'gx$',
  close_tab_left: 'gx0',
  close_tabs_except_current: 'gxx',
  duplicate_current_tab: 'yt',
  new_tab: 't',

  // History
  back_in_history: 'S',
  forward_in_history: 'D',
  go_to_parent: 'gu',
  go_to_root: 'gU',
  reload_page: 'r',
  reload_without_cache: 'ctrl+r',

  // Edit
  goto_edit_mode: 'i',
  focus_first_input: 'gi',
  focus_input: 'I',
  edit_input_with_vim: 'ctrl+i',
  edit_textarea_with_vim: 'ctrl+shift+i',

  // Clipboard
  yank_current_url: 'yy',
  yank_current_title: 'yt',
  yank_current_url_title: 'yT',
  yank_form_data: 'yg',
  yank_column_of_table: 'yc',
  yank_rows_of_table: 'yr',
  yank_cell_of_table: 'yd',
  paste_from_clipboard: 'p',
  paste_from_clipboard_new_tab: 'P',
  paste_from_primary: 'pp',
  paste_from_primary_new_tab: 'PP',

  // Search
  search_forward: '/',
  search_backward: '?',
  search_next: 'n',
  search_previous: 'N',
  search_selected_forward: '*',
  search_selected_backward: '#',
  clear_search_highlight: 'ctrl+h',

  // Visual Mode
  toggle_visual_mode: 'v',
  visual_mode_line: 'V',
  visual_mode_word: 'vw',
  visual_mode_sentence: 'vs',
  visual_mode_paragraph: 'vp',
  restore_visual_marks: 'ctrl+v',
  yank_selected_text: 'y',

  // Settings
  open_settings: ';;',
  open_search_engines: 'se',
  open_clipboard: 'sk',

  // Chrome URLs
  open_downloads: 'gd',
  open_history: 'gh',
  open_extensions: 'ge',
  open_settings_page: 'gs',
  open_chrome_cache: 'gc',
  open_chrome_inspect: 'si',

  // Bookmarks
  add_current_url_bookmark: 'ab',
  open_bookmark: 'b',

  // Sessions
  save_session: 'ZZ',
  restore_session: 'ZR',

  // Window
  new_window: 'W',
  close_window: 'ctrl+w',

  // Mouse Click
  mouse_out: 'cf',
  mouse_over: 'cv',
  mouse_click: 'cq',

  // Omnibar
  open_omnibar: 'og',
  open_omnibar_for_bookmarks: 'ob',
  open_omnibar_for_history: 'oh',
  open_omnibar_for_urls: 'ox',
  open_omnibar_for_tabs: 'ot',
  open_omnibar_for_windows: 'ow',
  open_omnibar_for_commands: ':',

  // Help
  show_help: '?',

  // Proxy
  toggle_proxy: 'cp',

  // Miscellaneous
  enter_passthrough_mode: 'alt+s',
  reset: 'ctrl+alt+r',
  toggle_blacklist: 'alt+i',
  edit_url: 'su',
  edit_url_new_tab: 'sU',
  increment_number: 'ctrl+a',
  decrement_number: 'ctrl+x',

  // Frame Navigation
  focus_frame: 'w',

  // PDF
  next_page_pdf: 'ctrl+j',
  previous_page_pdf: 'ctrl+k',

  // Insert Mode (when in input fields)
  escape_insert_mode: 'ctrl+[',

  // Caret Mode
  toggle_caret_mode: 'ctrl+v',

  // Mark
  jump_to_mark: "'",
  set_mark: 'm',

  // Plugin specific
  open_newtab_page: 'on',
} as const;

function buildBindings(): void {
	const enabledKeys: string[] = [];

	for (const [key, value] of Object.entries(Bindings)) {
		enabledKeys.push(Bindings[key as keyof typeof Bindings]);
	}
};

export {}; // Make this a module