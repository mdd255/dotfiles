"use strict";
(() => {
  // types.d.ts
  var Bindings = {
    // Help
    toggle_surfingkeys: "alt+s",
    enter_passthrough_mode: "alt+i",
    enter_ephemeral_mode: "p",
    show_usage: "?",
    show_last_action: ";ql",
    repeat_last_action: ".",
    // Mouse Click
    open_multiple_links: "cf",
    go_first_edit_box: "gi",
    open_link_non_active_new_tab: "gf",
    click_previous_link: "[[",
    click_next_link: "]]",
    mouse_out_element: ";m",
    display_hints_scrollable: ";fs",
    download_image: ";di",
    go_edit_box: "i",
    go_edit_box_vim: "I",
    enter_regional_hints: "L",
    open_detected_links: "O",
    open_link: "f",
    open_link_active_new_tab: "af",
    open_link_non_active_new_tab_alt: "C",
    mouse_over_elements: "ctrl+h",
    mouse_out_elements: "ctrl+j",
    go_edit_box_vim_alt: "ctrl+i",
    click_image_button: "q",
    // Scroll Page / Element
    scroll_all_left: "0",
    reset_scroll_target: "cS",
    change_scroll_target: "cs",
    scroll_half_page_up: "u",
    scroll_full_page_up: "U",
    scroll_half_page_down: "d",
    scroll_full_page_down: "P",
    scroll_to_top: "gg",
    scroll_to_bottom: "G",
    scroll_down: "j",
    scroll_up: "k",
    scroll_left: "h",
    scroll_right: "l",
    scroll_all_right: "$",
    scroll_percentage: "%",
    focus_top_window: ";w",
    switch_frames: "w",
    // Page Navigation
    go_up_path: "gu",
    go_playing_tab: "gp",
    go_first_active_tab: "gt",
    go_last_active_tab: "gp",
    reload_no_query: "g?",
    reload_no_fragment: "g#",
    go_root_url: "gU",
    edit_url_vim_new: ";u",
    edit_url_vim_reload: ";U",
    go_tab_history_back: "B",
    go_tab_history_forward: "F",
    go_last_used_tab: "ctrl+6",
    go_back_history: "S",
    go_forward_history: "D",
    reload_page: "r",
    // Tabs
    duplicate_current_tab: "yt",
    duplicate_current_tab_background: "yT",
    go_first_tab: "g0",
    go_last_tab: "g$",
    close_tabs_left: "gx0",
    close_tab_right: "gxT",
    close_tabs_right: "gx$",
    close_tabs_except_current: "gxx",
    close_playing_tab: "gxp",
    go_one_tab_left: "E",
    go_one_tab_right: "R",
    choose_tab: "T",
    gather_filtered_tabs: ";gt",
    gather_all_tabs: ";gw",
    zoom_reset: "zr",
    zoom_in: "zi",
    zoom_out: "zo",
    pin_unpin_tab: "alt+p",
    mute_unmute_tab: "alt+m",
    open_new_tab: "on",
    close_current_tab: "x",
    restore_closed_tab: "X",
    move_tab_another_window: "W",
    move_tab_left: "<<",
    move_tab_right: ">>",
    // Sessions
    save_session_quit: "ZZ",
    restore_last_session: "ZR",
    // Search Engines
    search_selected_google: "sg",
    search_selected_duckduckgo: "sd",
    search_selected_baidu: "sb",
    search_selected_wikipedia: "se",
    search_selected_bing: "ss",
    search_selected_stackoverflow: "so",
    search_selected_github: "sh",
    search_selected_youtube: "sy",
    // Clipboard
    capture_current_page: "y6",
    capture_scrolling_element: "ys",
    yank_text_element: "yv",
    yank_multiple_elements: "ymv",
    copy_multiple_link_urls: "yma",
    copy_multiple_columns: "ymc",
    capture_current_page_alt: "yg",
    copy_link_url: "ya",
    copy_column_table: "yc",
    copy_pre_text: "yq",
    copy_current_url: "yy",
    copy_current_title: "yt",
    copy_current_host: "yh",
    copy_current_title_url: "yT",
    copy_query_history: "yQ",
    copy_form_data_json: "yf",
    copy_form_data_post: "yp",
    copy_downloading_url: "yd",
    query_word_hints: "cq",
    open_selected_link_clipboard: "cc",
    paste_html_current: ";pp",
    // Omnibar - missing
    open_url_current: "go",
    open_omnibar_translation: "Q",
    bookmark_current_selected: "ab",
    open_incognito_window: "oi",
    open_url_vim_marks: "om",
    open_omnibar_google: "og",
    open_omnibar_duckduckgo: "od",
    open_omnibar_baidu: "ob",
    open_omnibar_wikipedia: "oe",
    open_omnibar_bing: "ow",
    open_omnibar_stackoverflow: "os",
    open_omnibar_youtube: "oy",
    open_recently_closed: "ox",
    open_url_history: "oh",
    open_opened_url_current: "H",
    open_commands: ":",
    open_llm_chat: "A",
    open_url: "t",
    open_bookmark: "b",
    // Visual Mode
    find_current_page: "/",
    enter_visual_mode_select: "zv",
    restore_visual_mode: "V",
    toggle_visual_mode: "v",
    find_selected_current: "*",
    toggle_visual_mode_alt: ";",
    next_found_text: "n",
    previous_found_text: "N",
    backward_lineboundary: "0",
    forward_character: "l",
    backward_character: "h",
    forward_line: "j",
    backward_line: "k",
    forward_word: "w",
    forward_word_alt: "e",
    backward_word: "b",
    forward_sentence: ")",
    backward_sentence: "(",
    forward_paragraph: "}",
    backward_paragraph: "{",
    forward_lineboundary_end: "$",
    forward_documentboundary: "G",
    backward_documentboundary: "gg",
    read_selected_text: "gr",
    go_other_end_highlighted: "o",
    search_word_cursor: "*",
    click_node_cursor: "Enter",
    click_node_cursor_shift: "Shift+Enter",
    make_cursor_top_window: "zt",
    make_cursor_center_window: "zz",
    make_cursor_bottom_window: "zb",
    forward_next_char: "f",
    backward_next_char: "F",
    repeat_latest_f: ";",
    repeat_latest_f_opposite: ",",
    expand_selection_parent: "p",
    select_word_line_sentence_paragraph: "V",
    backward_20_lines: "ctrl+u",
    forward_20_lines: "ctrl+d",
    translate_selected_google: "t",
    translate_word_cursor: "q",
    // Settings
    preview_markdown: ";pm",
    edit_settings: ";e",
    open_neovim: ";v",
    // Chrome URLs
    open_chrome_about: "ga",
    open_chrome_bookmarks: "gb",
    open_chrome_cache: "gc",
    open_chrome_downloads: "gd",
    open_chrome_history: "gh",
    open_chrome_cookies: "gk",
    open_chrome_extensions: "ge",
    open_chrome_net_internals: "gn",
    view_page_source: "gs",
    open_chrome_inspect: "si",
    close_downloads_shelf: ";j",
    // Vim-like marks
    add_current_url_vim_marks: "m",
    jump_vim_mark: "'",
    jump_vim_mark_new_tab: "ctrl+'",
    // Insert Mode
    move_cursor_end_line: "ctrl+e",
    move_cursor_beginning_line: "ctrl+a",
    delete_all_entered_before: "ctrl+u",
    move_cursor_backward_word: "alt+b",
    move_cursor_forward_word: "alt+f",
    delete_word_backwards: "alt+w",
    delete_word_forwards: "alt+d",
    exit_insert_mode: "Esc",
    toggle_quotes_input: "ctrl+'",
    open_vim_editor_current: "ctrl+i",
    open_neovim_current: "ctrl+alt+i",
    // Proxy
    toggle_proxy_current: "cp",
    set_proxy_always: ";pa",
    set_proxy_byhost: ";pb",
    set_proxy_direct: ";pd",
    set_proxy_system: ";ps",
    set_proxy_clear: ";pc",
    copy_proxy_info: ";cp",
    apply_proxy_clipboard: ";ap",
    // Misc
    read_selected_text_clipboard: "gr",
    toggle_pdf_viewer: ";s",
    put_histories_clipboard: ";ph",
    translate_selected_google_alt: ";t",
    delete_history_older_30: ";dh",
    remove_bookmark_current: ";db",
    yank_histories: ";yh",
    // Additional functionality from help doc
    restore_settings_clipboard: ";pj",
    fill_form_data_yf: ";pf",
    clear_all_urls_queue: ";cq",
    show_results_previous: "ctrl+,",
    copy_selected_item_urls: "ctrl+c",
    delete_items_bookmark_history: "ctrl+d",
    resort_history_visit_last: "ctrl+r",
    close_omnibar: "Esc",
    create_vim_mark_selected: "ctrl+m",
    forward_cycle_candidates: "Tab",
    backward_cycle_candidates: "Shift+Tab",
    forward_cycle_input_history: "ctrl+n",
    backward_cycle_input_history: "ctrl+p"
  };

  // bindings.ts
  var customBindings = {
    next_found_text: "m",
    previous_found_text: "M",
    display_hints_scrollable: "w",
    scroll_half_page_up: "e",
    scroll_half_page_down: "n",
    // scroll_right: 'i',
    go_edit_box: "o",
    go_edit_box_vim: "O",
    move_tab_left: "<",
    move_tab_right: ">",
    go_back_history: "H",
    go_forward_history: "I",
    close_current_tab: "q",
    copy_current_url: "yy"
  };
  function buildBindings() {
    for (const [key, customBindKey] of Object.entries(customBindings)) {
      const defaultBindKey = Bindings[key];
      api.map(customBindKey, defaultBindKey);
    }
  }

  // theme.ts
  api.Hints.style("border: solid 1px #3D3E3E; color:#F92660; background: initial; background-color: #272822; font-family: Maple Mono Freeze; box-shadow: 3px 3px 5px rgba(0, 0, 0, 0.8);");
  api.Hints.style("border: solid 1px #3D3E3E !important; padding: 1px !important; color: #A6E22E !important; background: #272822 !important; font-family: Maple Mono Freeze !important; box-shadow: 3px 3px 5px rgba(0, 0, 0, 0.8) !important;", "text");
  api.Visual.style("marks", "background-color: #A6E22E99;");
  api.Visual.style("cursor", "background-color: #F92660;");
  settings.theme = `
.sk_theme {
    font-family: Maple Mono Freeze,Input Sans Condensed, Charcoal, sans-serif;
    font-size: 10pt;
    background: #282828;
    color: #ebdbb2;
}
.sk_theme tbody {
    color: #b8bb26;
}
.sk_theme input {
    color: #d9dce0;
}
.sk_theme .url {
    color: #38971a;
}
.sk_theme .annotation {
    color: #b16286;
}

#sk_omnibar {
    width: 60%;
    left:20%;
    box-shadow: 0px 30px 50px rgba(0, 0, 0, 0.8);
}

.sk_omnibar_middle {
	top: 15%;
	border-radius: 10px;
}


.sk_theme .omnibar_highlight {
    color: #ebdbb2;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #282828;
}

.sk_theme #sk_omnibarSearchResult {
    max-height: 60vh;
    overflow: hidden;
    margin: 0rem 0rem;
}



#sk_omnibarSearchResult > ul {
	padding: 1.0em;
}

.sk_theme #sk_omnibarSearchResult ul li {
    margin-block: 0.5rem;
    padding-left: 0.4rem;
}

.sk_theme #sk_omnibarSearchResult ul li.focused {
	background: #181818;
	border-color: #181818;
	border-radius: 12px;
	position: relative;
	box-shadow: 1px 3px 5px rgba(0, 0, 0, 0.8);
}


#sk_omnibarSearchArea > input {
	display: inline-block;
	width: 100%;
	flex: 1;
	font-size: 20px;
	margin-bottom: 0;
	padding: 0px 0px 0px 0.5rem;
	background: transparent;
	border-style: none;
	outline: none;
	padding-left: 18px;
}


#sk_tabs {
	position: fixed;
	top: 0;
	left: 0;
    background-color: rgba(0, 0, 0, 0);
	overflow: auto;
	z-index: 2147483000;
    box-shadow: 0px 30px 50px rgba(0, 0, 0, 0.8);
	margin-left: 1rem;
	margin-top: 1.5rem;
    border: solid 1px #282828;
    border-radius: 15px;
    background-color: #282828; 
    padding-top: 10px;
    padding-bottom: 10px;

}

#sk_tabs div.sk_tab {
	vertical-align: bottom;
	justify-items: center;
	border-radius: 0px;
    background: #282828;
    //background: #181818 !important;

	margin: 0px; 
	box-shadow: 0px 0px 0px 0px rgba(245, 245, 0, 0.3); 
	box-shadow: 0px 0px 0px 0px rgba(0, 0, 0, 0.8) !important; 

	/* padding-top: 2px; */
	border-top: solid 0px black; 
	margin-block: 0rem;
}


#sk_tabs div.sk_tab:not(:has(.sk_tab_hint)) {
	background-color: #181818 !important;
	box-shadow: 1px 3px 5px rgba(0, 0, 0, 0.8) !important;
	border: 1px solid #181818;
	border-radius: 20px;
	position: relative;
	z-index: 1;
	margin-left: 1.8rem;
	padding-left: 0rem;
	margin-right: 0.7rem;
}


#sk_tabs div.sk_tab_title {
	display: inline-block;
	vertical-align: middle;
	font-size: 10pt;
	white-space: nowrap;
	text-overflow: ellipsis;
	overflow: hidden;
	padding-left: 5px;
	color: #ebdbb2;
}



#sk_tabs.vertical div.sk_tab_hint {
    position: inherit;
    left: 8pt;
    margin-top: 3px;
    border: solid 1px #3D3E3E; color:#F92660; background: initial; background-color: #272822; font-family: Maple Mono Freeze;
    box-shadow: 3px 3px 5px rgba(0, 0, 0, 0.8);
}

#sk_tabs.vertical div.sk_tab_wrap {
	display: inline-block;
	margin-left: 0pt;
	margin-top: 0px;
	padding-left: 15px;
}

#sk_tabs.vertical div.sk_tab_title {
	min-width: 100pt;
	max-width: 20vw;
}

#sk_usage, #sk_popup, #sk_editor {
	overflow: auto;
	position: fixed;
	width: 80%;
	max-height: 80%;
	top: 10%;
	left: 10%;
	text-align: left;
	box-shadow: 0px 30px 50px rgba(0, 0, 0, 0.8);
	z-index: 2147483298;
	padding: 1rem;
	border: 1px solid #282828;
	border-radius: 10px;
}

#sk_keystroke {
	padding: 6px;
	position: fixed;
	float: right;
	bottom: 0px;
	z-index: 2147483000;
	right: 0px;
	background: #282828;
	color: #fff;
	border: 1px solid #181818;
	border-radius: 10px;
	margin-bottom: 1rem;
	margin-right: 1rem;
	box-shadow: 0px 30px 50px rgba(0, 0, 0, 0.8);
}

#sk_status {
	position: fixed;
	/* top: 0; */
	bottom: 0;
	right: 39%;
	z-index: 2147483000;
	padding: 8px 8px 4px 8px;
	border-radius: 5px;
	border: 1px solid #282828;
	font-size: 12px;
	box-shadow: 0px 20px 40px 2px rgba(0, 0, 0, 1);
	/* margin-bottom: 1rem; */
	width: 20%;
	margin-bottom: 1rem;
}


#sk_omnibarSearchArea {
    border-bottom: 0px solid #282828;
}


#sk_omnibarSearchArea .resultPage {
	display: inline-block;
    font-size: 12pt;
    font-style: italic;
	width: auto;
}

#sk_omnibarSearchResult li div.url {
	font-weight: normal;
	white-space: nowrap;
	color: #aaa;
}

.sk_theme .omnibar_highlight {
	color: #11eb11;
	font-weight: bold;
}

.sk_theme .omnibar_folder {
	border: 1px solid #188888;
	border-radius: 5px;
	background: #188888;
	color: #aaa;
	box-shadow: 1px 1px 5px rgba(0, 8, 8, 1);
}
.sk_theme .omnibar_timestamp {
	background: #cc4b9c;
	border: 1px solid #cc4b9c;
	border-radius: 5px;
	color: #aaa;
	box-shadow: 1px 1px 5px rgb(0, 8, 8);
}
#sk_omnibarSearchResult li div.title {
	text-align: left;
	max-width: 100%;
	white-space: nowrap;
	overflow: auto;
}

.sk_theme .separator {
	color: #282828;
}

.sk_theme .prompt{
	color: #aaa;
	background-color: #181818;
	border-radius: 10px;
	padding-left: 22px;
	padding-right: 21px;
	/* padding: ; */
	font-weight: bold;
	box-shadow: 1px 3px 5px rgba(0, 0, 0, 0.8);
}



#sk_status, #sk_find {
	font-size: 10pt;
	font-weight: bold;
    text-align: center;
    padding-right: 8px;
}


#sk_status span[style*="border-right: 1px solid rgb(153, 153, 153);"] {
    display: none;
}

`;

  // index.ts
  buildBindings();
})();
