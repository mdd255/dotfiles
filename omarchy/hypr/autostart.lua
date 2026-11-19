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

-- Remember each monitor's active workspace so it can be restored after lock/DPMS re-add.
local last = {}
local frozen = false

local function snapshot()
	if frozen then
		return
	end
	for _, m in ipairs(hl.get_monitors()) do
		local ws = m.active_workspace
		if ws and ws.id and ws.id > 0 then
			last[m.name] = ws.id
		end
	end
end

local function restore()
	for name, id in pairs(last) do
		local monitor = hl.get_monitor(name)
		if monitor and hl.get_workspace(id) then
			monitor:set_workspace({ workspace = id })
		end
	end
	hl.dispatch(hl.dsp.focus({ monitor = "eDP-1" }))
end

hl.on("workspace.active", snapshot)
hl.on("monitor.focused", snapshot)

hl.on("monitor.added", function()
	frozen = true

	hl.timer(function()
		pin_workspaces()
		restore()
		frozen = false
		snapshot()
	end, { type = "oneshot", timeout = 1500 })
end)

hl.on("hyprland.start", function()
	-- pin_workspaces()

	-- eDP-1
	hl.exec_cmd(o.launch('chromium --profile-directory="Profile 1"'), { workspace = "1 silent" })
	hl.exec_cmd(o.launch('chromium --profile-directory="Default"'), { workspace = "1 silent" })

	-- HDMI-A-1
	hl.exec_cmd(o.launch("kitty"), { workspace = "2 silent" })
	hl.exec_cmd(o.launch("neovide"), { workspace = "2 silent" })

	-- DP-3
	hl.exec_cmd(o.launch("neovide"), { workspace = "3 silent" })
end)
