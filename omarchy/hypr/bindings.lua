local term = "kitty"
local browser = "chromium"
local editor = "neovide"
local script = os.getenv("HOME") .. "/.config/dotfiles/omarchy/scripts"

-- App bindings
o.bind("ALT + RETURN", "Terminal", term)
o.bind("ALT + B", "Browser", browser)
o.bind("ALT + W", "Editor", editor)

-- Window controls
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

-- Workspace controls (colemak home row). Each key targets a fixed monitor and slot,
-- and jumps to that monitor. Omarchy gives each monitor its own workspaces 1-10
-- (default/hypr/monitor-workspaces.lua), so go through o.workspaces, not raw ids.
local workspace_targets = {
	{ key = "N", monitor = "eDP-1", slot = 1 },
	{ key = "E", monitor = "HDMI-A-1", slot = 1 },
	{ key = "I", monitor = "DP-3", slot = 1 },
}

-- Focus the monitor first: o.workspaces.focus alone left focus on the old monitor.
local function focus_workspace(target)
	return function()
		hl.dispatch(hl.dsp.focus({ monitor = target.monitor }))
		hl.dispatch(o.workspaces.focus(target.slot, target.monitor))
	end
end

local function move_window_to(target)
	return function()
		local window = hl.get_active_window()
		local monitor = hl.get_monitor(target.monitor)

		if not (window and monitor) then
			return
		end

		focus_workspace(target)()

		local id = o.workspaces.workspace_id(monitor, target.slot)

		hl.dispatch(hl.dsp.window.move({
			workspace = tostring(id),
			follow = true,
			window = "address:" .. window.address,
		}))
	end
end

for _, target in ipairs(workspace_targets) do
	local label = target.monitor .. " " .. target.slot

	o.bind("SUPER + " .. target.key, "Switch to " .. label, focus_workspace(target))
	o.bind("CTRL + SUPER + " .. target.key, "Move window to " .. label, move_window_to(target))
end

-- Scripts
o.bind("ALT + K", "Events", script .. "/khal-view.js")
o.bind("SUPER + V", "VPN toggle", script .. "/vpn.js toggle")
o.bind("SUPER + SPACE", "Change method", script .. "/fcit5-custom.js")

-- Picker
o.bind("SUPER + A", "Audio picker", "omarchy-shell shell toggle omarchy.audio")
o.bind("SUPER + R", "Bluetooth picker", "omarchy-shell shell toggle omarchy.bluetooth")
o.bind("SUPER + S", "Wifi picker", "omarchy-shell shell toggle omarchy.network")
o.bind("SUPER + T", "Power picker", "omarchy-shell shell toggle omarchy.power")
o.bind("SUPER + D", "Superwhisper", "omarchy-shell shell toggle superwhisper.panel")
o.bind("SUPER + G", "Display picker", "omarchy-shell shell toggle omarchy.monitor")

-- Misc
o.bind("ALT + ESCAPE", "Application", "omarchy-menu toggle apps")
o.bind("SUPER + ESCAPE", "Application", "omarchy-menu toggle system")
o.bind("ALT + TAB", "Omarchy menu", "omarchy-menu")
o.bind("SUPER + L", "Suspend", "omarchy-system-lock")
o.bind("CTRL + SUPER + Q", "Quit hyprland", "omarchy-system-logout")
o.bind("SUPER + SHIFT + R", "Reload config", "omarchy osd -i  -m 'Keybinds reloaded' -d 500 && hyprctl reload")
o.bind("SUPER + P", "Screenshot", "omarchy-capture-screenshot")
o.bind("ALT + P", "Screenrecord", "omarchy-capture-screenrecording")
o.bind("SUPER + TAB", "Indicators", "omarchy-menu toggle toggle")
o.bind(
	"SUPER + Y",
	"Clear notifications",
	"omarchy osd -i 󰎟 -m 'Notifications cleared' -d 500 && omarchy-shell notifications dismissAll"
)

-- Media
local repeat_locked = { locked = true, repeating = true }

o.bind("ALT + L", "Volume down", "omarchy-audio-output-volume lower", repeat_locked)
o.bind("ALT + U", "Volume up", "omarchy-audio-output-volume raise", repeat_locked)
o.bind("ALT + Y", "Mute", "omarchy-audio-output-volume mute-toggle", repeat_locked)
o.bind("ALT + semicolon", "Mute microphone", "omarchy-audio-input-mute", repeat_locked)
o.bind("ALT + J", "Next audio output", "omarchy-audio-output-switch", repeat_locked)

-- Brightness
o.bind("SUPER + X", "Brightness down", "omarchy-brightness-display 5%-", repeat_locked)
o.bind("SUPER + C", "Brightness up", "omarchy-brightness-display +5%", repeat_locked)

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
local function active_window_is_terminal(window)
	for _, tag in ipairs(window.tags or {}) do
		if tag:gsub("%*$", "") == "terminal" then
			return true
		end
	end

	return false
end

local function universal_clipboard_shortcut(default_mods, default_key, native_mods, native_key)
	return function()
		local window = hl.get_active_window()

		-- Neovide maps Alt+C/X/A/V itself (lazyvim/lua/config/linux.lua), like terminals.
		if window and (active_window_is_terminal(window) or window.class == "neovide") then
			send_shortcut_once(native_mods, native_key)()
		else
			send_shortcut_once(default_mods, default_key)()
		end
	end
end

-- Terminals and neovide get Alt forwarded unchanged; other apps get Ctrl.
o.bind("ALT + C", "Universal copy", universal_clipboard_shortcut("CTRL", "C", "ALT", "C"))
o.bind("ALT + X", "Universal cut", universal_clipboard_shortcut("CTRL", "X", "ALT", "X"))
o.bind("ALT + A", "Universal select all", universal_clipboard_shortcut("CTRL", "A", "ALT", "A"))
o.bind("ALT + V", "Universal paste", universal_clipboard_shortcut("CTRL", "V", "ALT", "V"))
o.bind("SUPER + Z", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")

-- Misc
o.bind("SUPER + SHIFT + E", "Email", "omarchy-shell shell summon omamail '{}'")
