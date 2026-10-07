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
		rounding = 0,
		active_opacity = 1,
		inactive_opacity = 1,
		fullscreen_opacity = 1,
		dim_inactive = false,
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
		font_family = "FiraCode Nerd Font",
		key_press_enables_dpms = true,
		exit_window_retains_fullscreen = false,
	},

	ecosystem = {
		no_update_news = true,
		no_donation_nag = true,
	},

	cursor = {
		invisible = false,
	},
})

-- Personal window rules.
o.window("Netsoft-com.netsoft.hubstaff", { size = { 340, 160 } })
o.window("dh.calendar", { float = true, size = { 850, 400 }, center = true })

-- Tiled windows stay borderless (general.border_size = 0); floating ones get a border.
o.window({ float = true }, { border_size = 1 })
