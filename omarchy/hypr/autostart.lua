-- o.launch_on_start("/home/dh/Hubstaff/HubstaffClient.bin.x86_64 --no-watchdog")

hl.on("hyprland.start", function()
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
