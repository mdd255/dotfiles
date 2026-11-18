-- o.launch_on_start("/home/dh/Hubstaff/HubstaffClient.bin.x86_64 --no-watchdog")

-- Omarchy's monitor-workspaces.lua gives each monitor its own block of ten
-- workspaces and reconciles on every monitor event, which overrides the
-- workspace_rule pins in monitors.lua while monitors are still coming up.
-- Re-pin after it: 2 (E) -> HDMI-A-1, 3 (I) -> DP-3.
local pins = { ["2"] = "HDMI-A-1", ["3"] = "DP-3" }

local function pin_workspaces()
	for id, name in pairs(pins) do
		local monitor = hl.get_monitor(name)
		if monitor then
			local workspace = hl.get_workspace(tonumber(id))
			if workspace and workspace.monitor and workspace.monitor.name ~= name then
				hl.dispatch(hl.dsp.workspace.move({ workspace = id, monitor = name }))
			end
			if not workspace then
				hl.dispatch(hl.dsp.focus({ monitor = name }))
				hl.dispatch(hl.dsp.focus({ workspace = id }))
			else
				monitor:set_workspace({ workspace = id })
			end
		end
	end
	hl.dispatch(hl.dsp.focus({ monitor = "eDP-1" }))
end

hl.on("monitor.added", function()
	hl.timer(pin_workspaces, { type = "oneshot", timeout = 1500 })
end)

hl.on("hyprland.start", function()
	pin_workspaces()

	-- eDP-1
	-- hl.exec_cmd(o.launch('brave --profile-directory="AA"'), { workspace = "1 silent" })
	hl.exec_cmd(o.launch('brave --profile-directory="ABD"'), { workspace = "1 silent" })

	-- HDMI-A-1
	hl.exec_cmd(o.launch("kitty"), { workspace = "2 silent" })
	hl.exec_cmd(o.launch("neovide"), { workspace = "2 silent" })

	-- DP-3
	-- hl.exec_cmd(o.launch("omarchy-shell shell summon omamail '{}'"), { workspace = "3 silent" })
	hl.exec_cmd(o.launch("neovide"), { workspace = "3 silent" })
end)
