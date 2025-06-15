"""Config Qtile."""

import subprocess
from typing import Any, List

from libqtile import bar, hook, layout
from libqtile.config import Match

from keymaps import keys, groups
from widgets import (
    init_screens,
    init_widgets_list,
    init_widgets_screen1,
    init_widgets_screen2,
    init_widgets_screen3,
    widget_defaults,
)


layout_theme = {
    "border_width": 0,
    "margin": 0,
    "border_focus": "white",
    "border_normal": "1D2330",
    "max_ratio": 0.75,
    "min_ratio": 0.25,
}

layouts = [
    # layout.Tile(**layout_theme),
    # layout.RatioTile(**layout_theme),
    # layout.Matrix(**layout_theme),
    # layout.Bsp(**layout_theme),
    # layout.MonadWide(**layout_theme),
    layout.MonadTall(**layout_theme),
    layout.Max(**layout_theme),
]


if __name__ in ["config", "__main__"]:
    screens = init_screens()
    widgets_list = init_widgets_list()
    widgets_screen1 = init_widgets_screen1()
    widgets_screen2 = init_widgets_screen2()
    widgets_screen3 = init_widgets_screen3()

mouse: List[Any] = []

dgroups_key_binder = None
dgroups_app_rules: List[Any] = []
main = None
follow_mouse_focus = False
bring_front_click = True
cursor_wrap = False

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="xmessage"),
        Match(wm_class="Pavucontrol"),
        Match(wm_class="Blueman-manager"),
        Match(wm_class="Arandr"),
    ]
)

auto_fullscreen = True
focus_on_window_activation = "smart"

@hook.subscribe.startup_once
def start_once():
    """Bootstrap qtile."""
    subprocess.Popen(["/usr/bin/ibus-daemon", "-d"])
    subprocess.Popen(["/usr/bin/xfce4-power-manager", "--daemon"])
    subprocess.Popen(["/usr/bin/xbanish", "-a"])

wmname = "LG3D"
