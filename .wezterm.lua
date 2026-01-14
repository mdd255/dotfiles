local wezterm = require("wezterm")

local config = wezterm.config_builder()
local action = wezterm.action
local ctrl = "CTRL"
local ctrl_shift = "CTRL|SHIFT"
local ctrl_cmd = "CTRL|CMD"
local alt = "ALT"

config.color_scheme = "AdventureTime"
config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 12.8
config.cell_width = 1
config.line_height = 0.9
config.disable_default_key_bindings = true
config.enable_wayland = false
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.exit_behavior = "Close"
config.warn_about_missing_glyphs = false
config.scrollback_lines = 10000
config.native_macos_fullscreen_mode = true

---@diagnostic disable-next-line: unused-local
local function format_win_tile(tab, pane, tabs, panes, conf)
	local tab_titles = {}

	for _, t in ipairs(tabs) do
		local title = t.active_pane.title

		if t.tab_title and #t.tab_title > 0 then
			title = t.tab_title
		end

		-- Add indicator for active tab
		if t.is_active then
			title = "" .. title .. ""
		end

		table.insert(tab_titles, title)
	end

	return " " .. table.concat(tab_titles, " ")
end

wezterm.on("format-window-title", format_win_tile)

config.colors = {
	background = "black",
	cursor_bg = "#6cb6eb",
	cursor_fg = "white",
	cursor_border = "red",
	selection_bg = "#6cb6eb",
	selection_fg = "white",
}

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.keys = {
	{
		key = "r",
		mods = ctrl,
		action = action.PromptInputLine({
			description = "New tab name",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "v",
		mods = alt,
		action = action.PasteFrom("Clipboard"),
	},
	{
		key = "p",
		mods = alt,
		action = action.ActivateCommandPalette,
	},
	{
		key = "f",
		mods = ctrl,
		action = action.Search({ CaseInSensitiveString = "" }),
	},
	{
		key = "t",
		mods = ctrl,
		action = wezterm.action_callback(function(window, pane)
			local tab = window:mux_window():spawn_tab({})
			window:perform_action(
				action.PromptInputLine({
					description = "New tab name",
					action = wezterm.action_callback(function(_, _, line)
						if line then
							tab:set_title(line)
						end
					end),
				}),
				pane
			)
		end),
	},
	{
		key = "q",
		mods = ctrl,
		action = action.CloseCurrentTab({ confirm = false }),
	},
	{
		key = "n",
		mods = ctrl,
		action = action.ScrollByPage(0.5),
	},
	{
		key = "e",
		mods = ctrl,
		action = action.ScrollByPage(-0.5),
	},
	{
		key = "v",
		mods = ctrl,
		action = action.ActivateCopyMode,
	},
	{
		key = "f",
		mods = ctrl_cmd,
		action = action.ToggleFullScreen,
	},
	{
		key = "Tab",
		mods = ctrl,
		action = action.ActivateTabRelative(1),
	},
	{
		key = "Tab",
		mods = ctrl_shift,
		action = action.ActivateTabRelative(-1),
	},
}

return config
