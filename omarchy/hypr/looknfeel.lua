-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		border_size = 0,
		gaps_in = 0,
		gaps_out = 0,
		layout = "monocle",
	},

	decoration = {
		rounding = 5,
		active_opacity = 1,
		inactive_opacity = 1,
		fullscreen_opacity = 1,
		dim_inactive = true,
		dim_strength = 0.1,
		shadow = {
			enabled = false,
		},
	},

	-- Max-like layout similar to qtile.
	master = {
		orientation = "center",
		new_on_top = true,
		new_status = "master",
		mfact = 0.5,
	},

	misc = {
		key_press_enables_dpms = true,
		exit_window_retains_fullscreen = false,
	},

	ecosystem = {
		no_update_news = true,
		no_donation_nag = true,
	},
})

-- Personal window rules.
o.window("Netsoft-com.netsoft.hubstaff", { size = "340 160", move = "monitor_w-340 monitor_h-160" })
