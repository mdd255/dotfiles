local wezterm = require("wezterm")

local config = wezterm.config_builder()
local action = wezterm.action
local ctrl = "CTRL"
local ctrl_cmd = "CTRL|CMD"
local alt = "ALT"

config.color_scheme = "AdventureTime"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 16
config.cell_width = 1
config.line_height = 1
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
	local title = ""

	for i = 1, #tabs, 1 do
		local current_tab = tabs[i]
		local tab_title = current_tab.tab_title

		if tab_title == "" then
			tab_title = "*"
		end

		if current_tab.is_active then
			title = string.format("%s %s", title, tab_title)
		else
			title = string.format("%s %s", title, tab_title)
		end
	end

	return title
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
		action = action.Multiple({
			action.SpawnTab({ DomainName = "unix" }),
		}),
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
}

return config
