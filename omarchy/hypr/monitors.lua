-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080", position = "0x0", scale = 1, transform = 1 })
hl.monitor({ output = "DP-3", mode = "1920x1080", position = "1080x0", scale = 1, transform = 2 })
hl.monitor({ output = "eDP-1", mode = "1920x1080", position = "1080x1080", scale = 1.25 })
