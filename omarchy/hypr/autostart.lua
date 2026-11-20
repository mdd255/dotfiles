-- Omarchy owns workspace placement per monitor (default/hypr/monitor-workspaces.lua).
-- Launch each app on slot 1 of its monitor; workspace_id resolves the monitor's block.
local function slot1(monitor_name)
	local monitor = hl.get_monitor(monitor_name)

	if monitor then
		return tostring(o.workspaces.workspace_id(monitor, 1)) .. " silent"
	end

	return "1 silent"
end

hl.on("hyprland.start", function()
	-- eDP-1
	hl.exec_cmd(o.launch('chromium --profile-directory="Profile 1"'), { workspace = slot1("eDP-1") })
	hl.exec_cmd(o.launch('chromium --profile-directory="Default"'), { workspace = slot1("eDP-1") })

	-- HDMI-A-1
	hl.exec_cmd(o.launch("kitty"), { workspace = slot1("HDMI-A-1") })
	hl.exec_cmd(o.launch("neovide"), { workspace = slot1("HDMI-A-1") })

	-- DP-3
	hl.exec_cmd(o.launch("neovide"), { workspace = slot1("DP-3") })
end)
