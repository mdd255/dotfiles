-- Omarchy owns workspace placement per monitor (default/hypr/monitor-workspaces.lua).
-- Launch each app on slot 1 of its monitor; workspace_id resolves the monitor's block.
-- At session start external monitors may not be connected yet, so wait for each
-- one instead of falling back to workspace 1 (which is eDP-1).
local MAX_TRIES = 20

local MONITOR = {
	LAPTOP = "eDP-1",
	HDMI = "HDMI-A-1",
	DP = "DP-3",
}

local function launch(monitor_name, command, tries)
	tries = tries or 0
	local monitor = hl.get_monitor(monitor_name)

	if not monitor then
		if tries < MAX_TRIES then
			hl.timer(function()
				launch(monitor_name, command, tries + 1)
			end, { type = "oneshot", timeout = 500 })
		end
		return
	end

	local workspace = tostring(o.workspaces.workspace_id(monitor, 1)) .. " silent"
	hl.exec_cmd(o.launch(command), { workspace = workspace })
end

hl.on("hyprland.start", function()
	-- eDP-1
	launch(MONITOR.LAPTOP, 'chromium --profile-directory="Profile 1"')
	launch(MONITOR.LAPTOP, 'chromium --profile-directory="Default"')

	-- HDMI-A-1
	launch(MONITOR.HDMI, "kitty")
	launch(MONITOR.HDMI, "neovide")

	-- DP-3
	launch(MONITOR.DP, "neovide")
end)
