-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- Focus the window if it exists, otherwise launch it.
local term = "kitty"
local browser = "brave"
local editor = "neovide"
local script = os.getenv("HOME") .. "/.config/dotfiles/omarchy/scripts"

-- App bindings
o.bind("ALT + RETURN", "Terminal", term)
o.bind("ALT + B", "Browser", browser)
o.bind("ALT + A", "Editor", editor)

-- Window controls
o.bind("ALT + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("ALT + T", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))

o.bind("ALT + Q", "Kill active", hl.dsp.window.close())
o.bind("ALT + O", "Cycle next", hl.dsp.layout("cyclenext"))
o.bind("ALT + SHIFT + TAB", "Cycle previous", hl.dsp.layout("cycleprev"))
o.bind("ALT + N", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("ALT + E", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("ALT + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("ALT + I", "Focus right", hl.dsp.focus({ direction = "r" }))
o.bind("ALT + SHIFT + N", "Swap down", hl.dsp.window.swap({ direction = "d" }))
o.bind("ALT + SHIFT + E", "Swap up", hl.dsp.window.swap({ direction = "u" }))
o.bind("ALT + SHIFT + H", "Swap left", hl.dsp.window.swap({ direction = "l" }))
o.bind("ALT + SHIFT + I", "Swap right", hl.dsp.window.swap({ direction = "r" }))

-- Workspace controls (colemak home row: N E I O H = 1..5)
local workspace_keys = { "N", "E", "I", "O", "H" }

for index, key in ipairs(workspace_keys) do
	local workspace = tostring(index)
	o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = workspace }))

	o.bind(
		"CTRL + SUPER + " .. key,
		"Move window to workspace " .. workspace,
		hl.dsp.window.move({ workspace = workspace })
	)
end

-- Scripts
o.bind("ALT + K", "Events", script .. "/khal-view.js")
o.bind("ALT + semicolon", "Hubstaff toggle", script .. "/hubstaff-toggle.js")
o.bind("SUPER + SPACE", "Change method", script .. "/fcit5-custom.js")

-- Picker
o.bind("SUPER + A", "Audio picker", "omarchy-shell shell toggle omarchy.audio")
o.bind("SUPER + R", "Bluetooth picker", "omarchy-shell shell toggle omarchy.bluetooth")
o.bind("SUPER + S", "Wifi picker", "omarchy-shell shell toggle omarchy.network")
o.bind("SUPER + T", "Power picker", "omarchy-shell shell toggle omarchy.power")

-- Misc
o.bind("ALT + ESCAPE", "Application", "omarchy-menu toggle apps")
o.bind("SUPER + ESCAPE", "Application", "omarchy-menu toggle system")
o.bind("ALT + TAB", "Omarchy menu", "omarchy-menu")
o.bind("SUPER + L", "Suspend", "hubstaff stop; omarchy-system-lock")
o.bind("CTRL + SUPER + Q", "Quit hyprland", "omarchy-system-logout")
o.bind("SUPER + SHIFT + R", "Reload config", "hyprctl reload")
o.bind("SUPER + P", "Screenshot", "omarchy-capture-screenshot")
o.bind("ALT + P", "Screenrecord", "omarchy-capture-screenrecording")

-- Media
local repeat_locked = { locked = true, repeating = true }

o.bind("ALT + l", "Volume down", "omarchy-audio-output-volume lower", repeat_locked)
o.bind("ALT + u", "Volume up", "omarchy-audio-output-volume raise", repeat_locked)
o.bind("ALT + y", "Mute", "omarchy-audio-output-volume mute-toggle", repeat_locked)
o.bind("ALT + semicolon", "Mute microphone", "omarchy-audio-input-mute", repeat_locked)
o.bind("ALT + j", "Next audio output", "omarchy-audio-output-switch", repeat_locked)

-- Brightness
o.bind("SUPER + Q", "Brightness down", "omarchy-brightness-display 5%-", repeat_locked)
o.bind("SUPER + W", "Brightness up", "omarchy-brightness-display +5%", repeat_locked)

-- Clipboard
local function send_shortcut_once(mods, key)
	return function()
		hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

		hl.timer(function()
			hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
		end, { timeout = 50, type = "oneshot" })
	end
end

-- Lean on the terminal tag from default/hypr/apps/terminals.lua so there's one
-- definition of what counts as a terminal. Dynamic tags carry a trailing "*".
local function active_window_is_terminal()
	local window = hl.get_active_window()

	if not window then
		return false
	end

	for _, tag in ipairs(window.tags or {}) do
		if tag:gsub("%*$", "") == "terminal" then
			return true
		end
	end

	return false
end

local function universal_clipboard_shortcut(default_mods, default_key, terminal_mods, terminal_key)
	return function()
		if active_window_is_terminal() then
			send_shortcut_once(terminal_mods, terminal_key)()
		else
			send_shortcut_once(default_mods, default_key)()
		end
	end
end

o.bind("SUPER + C", "Universal copy", universal_clipboard_shortcut("CTRL", "C", "CTRL", "Insert"))
o.bind("SUPER + V", "Universal paste", universal_clipboard_shortcut("CTRL", "V", "SHIFT", "Insert"))
o.bind("SUPER + X", "Universal cut", send_shortcut_once("CTRL", "X"))
o.bind("SUPER + Z", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")
