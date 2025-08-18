// TypeScript declarations for SurfingKeys API

declare global {
  interface SurfingKeysAPI {
    Hints: {
      style(css: string, mode?: string): void;
    };
    Visual: {
      style(element: string, css: string): void;
    };
    map(key: string, target: string, domain?: string): void;
    unmap(key: string, domain?: string): void;
    unmapAllExcept(keys: string[], domain?: RegExp)
    addSearchAlias(alias: string, name: string, url: string, suggestion?: string): void;
    removeSearchAlias(alias: string): void;
  }

  interface SurfingKeysSettings {
    theme: string;
    [key: string]: any;
  }

  const api: SurfingKeysAPI;
  const settings: SurfingKeysSettings;

}

export const Bindings = {
  // Help
  toggle_surfingkeys: 'alt+s',
  enter_passthrough_mode: 'alt+i',
  enter_ephemeral_mode: 'p',
  show_usage: '?',
  show_last_action: ';ql',
  repeat_last_action: '.',

  // Mouse Click
  open_multiple_links: 'cf',
  go_first_edit_box: 'gi',
  open_link_non_active_new_tab: 'gf',
  click_previous_link: '[[',
  click_next_link: ']]',
  mouse_out_element: ';m',
  display_hints_scrollable: ';fs',
  download_image: ';di',
  go_edit_box: 'i',
  go_edit_box_vim: 'I',
  enter_regional_hints: 'L',
  open_detected_links: 'O',
  open_link: 'f',
  open_link_active_new_tab: 'af',
  open_link_non_active_new_tab_alt: 'C',
  mouse_over_elements: 'ctrl+h',
  mouse_out_elements: 'ctrl+j',
  go_edit_box_vim_alt: 'ctrl+i',
  click_image_button: 'q',

  // Scroll Page / Element
  scroll_all_left: '0',
  reset_scroll_target: 'cS',
  change_scroll_target: 'cs',
  scroll_half_page_up: 'u',
  scroll_full_page_up: 'U',
  scroll_half_page_down: 'd',
  scroll_full_page_down: 'P',
  scroll_to_top: 'gg',
  scroll_to_bottom: 'G',
  scroll_down: 'j',
  scroll_up: 'k',
  scroll_left: 'h',
  scroll_right: 'l',
  scroll_all_right: '$',
  scroll_percentage: '%',
  focus_top_window: ';w',
  switch_frames: 'w',

  // Page Navigation
  go_up_path: 'gu',
  go_playing_tab: 'gp',
  go_first_active_tab: 'gt',
  go_last_active_tab: 'gp',
  reload_no_query: 'g?',
  reload_no_fragment: 'g#',
  go_root_url: 'gU',
  edit_url_vim_new: ';u',
  edit_url_vim_reload: ';U',
  go_tab_history_back: 'B',
  go_tab_history_forward: 'F',
  go_last_used_tab: 'ctrl+6',
  go_back_history: 'S',
  go_forward_history: 'D',
  reload_page: 'r',

  // Tabs
  duplicate_current_tab: 'yt',
  duplicate_current_tab_background: 'yT',
  go_first_tab: 'g0',
  go_last_tab: 'g$',
  close_tabs_left: 'gx0',
  close_tab_right: 'gxT',
  close_tabs_right: 'gx$',
  close_tabs_except_current: 'gxx',
  close_playing_tab: 'gxp',
  go_one_tab_left: 'E',
  go_one_tab_right: 'R',
  choose_tab: 'T',
  gather_filtered_tabs: ';gt',
  gather_all_tabs: ';gw',
  zoom_reset: 'zr',
  zoom_in: 'zi',
  zoom_out: 'zo',
  pin_unpin_tab: 'alt+p',
  mute_unmute_tab: 'alt+m',
  open_new_tab: 'on',
  close_current_tab: 'x',
  restore_closed_tab: 'X',
  move_tab_another_window: 'W',
  move_tab_left: '<<',
  move_tab_right: '>>',

  // Sessions
  save_session_quit: 'ZZ',
  restore_last_session: 'ZR',

  // Search Engines
  search_selected_google: 'sg',
  search_selected_duckduckgo: 'sd',
  search_selected_baidu: 'sb',
  search_selected_wikipedia: 'se',
  search_selected_bing: 'ss',
  search_selected_stackoverflow: 'so',
  search_selected_github: 'sh',
  search_selected_youtube: 'sy',

  // Clipboard
  capture_current_page: 'y6',
  capture_scrolling_element: 'ys',
  yank_text_element: 'yv',
  yank_multiple_elements: 'ymv',
  copy_multiple_link_urls: 'yma',
  copy_multiple_columns: 'ymc',
  capture_current_page_alt: 'yg',
  copy_link_url: 'ya',
  copy_column_table: 'yc',
  copy_pre_text: 'yq',
  copy_current_url: 'yy',
  copy_current_title: 'yt',
  copy_current_host: 'yh',
  copy_current_title_url: 'yT',
  copy_query_history: 'yQ',
  copy_form_data_json: 'yf',
  copy_form_data_post: 'yp',
  copy_downloading_url: 'yd',
  query_word_hints: 'cq',
  open_selected_link_clipboard: 'cc',
  paste_html_current: ';pp',

  // Omnibar - missing
  open_url_current: 'go',
  open_omnibar_translation: 'Q',
  bookmark_current_selected: 'ab',
  open_incognito_window: 'oi',
  open_url_vim_marks: 'om',
  open_omnibar_google: 'og',
  open_omnibar_duckduckgo: 'od',
  open_omnibar_baidu: 'ob',
  open_omnibar_wikipedia: 'oe',
  open_omnibar_bing: 'ow',
  open_omnibar_stackoverflow: 'os',
  open_omnibar_youtube: 'oy',
  open_recently_closed: 'ox',
  open_url_history: 'oh',
  open_opened_url_current: 'H',
  open_commands: ':',
  open_llm_chat: 'A',
  open_url: 't',
  open_bookmark: 'b',

  // Visual Mode
  find_current_page: '/',
  enter_visual_mode_select: 'zv',
  restore_visual_mode: 'V',
  toggle_visual_mode: 'v',
  find_selected_current: '*',
  toggle_visual_mode_alt: ';',
  next_found_text: 'n',
  previous_found_text: 'N',
  backward_lineboundary: '0',
  forward_character: 'l',
  backward_character: 'h',
  forward_line: 'j',
  backward_line: 'k',
  forward_word: 'w',
  forward_word_alt: 'e',
  backward_word: 'b',
  forward_sentence: ')',
  backward_sentence: '(',
  forward_paragraph: '}',
  backward_paragraph: '{',
  forward_lineboundary_end: '$',
  forward_documentboundary: 'G',
  backward_documentboundary: 'gg',
  read_selected_text: 'gr',
  go_other_end_highlighted: 'o',
  search_word_cursor: '*',
  click_node_cursor: 'Enter',
  click_node_cursor_shift: 'Shift+Enter',
  make_cursor_top_window: 'zt',
  make_cursor_center_window: 'zz',
  make_cursor_bottom_window: 'zb',
  forward_next_char: 'f',
  backward_next_char: 'F',
  repeat_latest_f: ';',
  repeat_latest_f_opposite: ',',
  expand_selection_parent: 'p',
  select_word_line_sentence_paragraph: 'V',
  backward_20_lines: 'ctrl+u',
  forward_20_lines: 'ctrl+d',
  translate_selected_google: 't',
  translate_word_cursor: 'q',

  // Settings
  preview_markdown: ';pm',
  edit_settings: ';e',
  open_neovim: ';v',

  // Chrome URLs
  open_chrome_about: 'ga',
  open_chrome_bookmarks: 'gb',
  open_chrome_cache: 'gc',
  open_chrome_downloads: 'gd',
  open_chrome_history: 'gh',
  open_chrome_cookies: 'gk',
  open_chrome_extensions: 'ge',
  open_chrome_net_internals: 'gn',
  view_page_source: 'gs',
  open_chrome_inspect: 'si',
  close_downloads_shelf: ';j',

  // Vim-like marks
  add_current_url_vim_marks: 'm',
  jump_vim_mark: "'",
  jump_vim_mark_new_tab: 'ctrl+\'',

  // Insert Mode
  move_cursor_end_line: 'ctrl+e',
  move_cursor_beginning_line: 'ctrl+a',
  delete_all_entered_before: 'ctrl+u',
  move_cursor_backward_word: 'alt+b',
  move_cursor_forward_word: 'alt+f',
  delete_word_backwards: 'alt+w',
  delete_word_forwards: 'alt+d',
  exit_insert_mode: 'Esc',
  toggle_quotes_input: 'ctrl+\'',
  open_vim_editor_current: 'ctrl+i',
  open_neovim_current: 'ctrl+alt+i',

  // Proxy
  toggle_proxy_current: 'cp',
  set_proxy_always: ';pa',
  set_proxy_byhost: ';pb',
  set_proxy_direct: ';pd',
  set_proxy_system: ';ps',
  set_proxy_clear: ';pc',
  copy_proxy_info: ';cp',
  apply_proxy_clipboard: ';ap',

  // Misc
  read_selected_text_clipboard: 'gr',
  toggle_pdf_viewer: ';s',
  put_histories_clipboard: ';ph',
  translate_selected_google_alt: ';t',
  delete_history_older_30: ';dh',
  remove_bookmark_current: ';db',
  yank_histories: ';yh',

  // Additional functionality from help doc
  restore_settings_clipboard: ';pj',
  fill_form_data_yf: ';pf',
  clear_all_urls_queue: ';cq',
  show_results_previous: 'ctrl+,',
  copy_selected_item_urls: 'ctrl+c',
  delete_items_bookmark_history: 'ctrl+d',
  resort_history_visit_last: 'ctrl+r',
  close_omnibar: 'Esc',
  create_vim_mark_selected: 'ctrl+m',
  forward_cycle_candidates: 'Tab',
  backward_cycle_candidates: 'Shift+Tab',
  forward_cycle_input_history: 'ctrl+n',
  backward_cycle_input_history: 'ctrl+p',
} as const;