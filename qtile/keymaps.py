from os import path
from libqtile.lazy import lazy
from libqtile.config import Key, Group

TERM = "wezterm start --class Code"
ALT = "mod1"
HOME = path.expanduser("~")
QTILE_DIR = HOME + "/.config/qtile"
CONTROL = "control"
WIN = "mod4"
SHIFT = "shift"
MOUSE_MOV_DIFF = 20
SOUND_CMD = "paplay /usr/share/sounds/freedesktop/stereo/bell.oga"

group_keys = {
    "1": "n",
    "2": "e",
    "3": "i",
    "4": "o",
    "5": "l",
    "6": "u",
    "7": "y",
    "8": "semicolon",
}

group_names = [
    ("", {"layout": "max"}),
    ("", {"layout": "max"}),
    ("󰌀", {"layout": "max"}),
    ("", {"layout": "max"}),
    ("", {"layout": "max"}),
    ("", {"layout": "max"}),
    ("", {"layout": "max"}),
    ("", {"layout": "max"}),
]

groups = [Group(name, **kwargs) for name, kwargs in group_names]


def notify_cmd(msg: str, title="System", time_out_ms=1500):
    return f'notify-send "{title}" "{msg}" --expire-time={time_out_ms}'


keys = [
    # The essentials
    Key(
        [ALT],
        "a",
        lazy.spawn("neovide --x11-wm-class Code --x11-wm-class-instance Code"),
        desc="Launch default IDE",
    ),
    Key(
        [ALT],
        "Return",
        lazy.spawn(TERM),
        desc="Launch default terminal",
    ),
    Key(
        [ALT],
        "Escape",
        lazy.spawn(HOME + "/.config/rofi/scripts/menu"),
        desc="Rofi show running applications",
    ),
    Key(
        [CONTROL],
        "Escape",
        lazy.spawn(HOME + "/.config/rofi/scripts/cmd"),
        desc="Rofi show running applications",
    ),
    Key(
        [ALT],
        "Tab",
        lazy.spawn(HOME + "/.config/rofi/scripts/index"),
        desc="Rofi show running applications",
    ),
    Key(
        [ALT],
        "b",
        lazy.spawn("brave"),
        desc="Start web browser",
    ),
    Key(
        [ALT],
        "f",
        lazy.next_layout(),
        desc="Toggle through layouts",
    ),
    Key(
        [ALT, SHIFT],
        "o",
        lazy.window.kill(),
        desc="Kill active window",
    ),
    Key(
        [ALT],
        "q",
        lazy.window.kill(),
        desc="Kill active window",
    ),
    Key(
        [ALT, SHIFT],
        "r",
        lazy.spawn(SOUND_CMD),
        lazy.restart(),
        desc="Restart Qtile",
    ),
    Key(
        [ALT, SHIFT],
        "q",
        lazy.shutdown(),
        desc="Shutdown Qtile",
    ),
    # Switch focus of monitors
    Key(
        [ALT],
        "o",
        lazy.spawn(QTILE_DIR + "/.init-scripts/smart-screen-switch next"),
        desc="Move focus to next monitor",
    ),
    Key(
        [ALT, SHIFT],
        "o",
        lazy.spawn(QTILE_DIR + "/.init-scripts/smart-screen-switch prev"),
        desc="Move focus to previous monitor",
    ),
    # Window controls
    Key(
        [ALT],
        "h",
        lazy.layout.right(),
        desc="Move focus right in current stack pane",
    ),
    Key(
        [ALT],
        "e",
        lazy.layout.down(),
        desc="Move focus down in current stack pane",
    ),
    Key(
        [ALT],
        "n",
        lazy.layout.up(),
        desc="Move focus up in current stack pane",
    ),
    Key(
        [ALT, SHIFT],
        "h",
        lazy.layout.swap_left(),
        desc="Move windows left in current stack",
    ),
    Key(
        [ALT, SHIFT],
        "i",
        lazy.layout.swap_right(),
        desc="Move windows right in current stack",
    ),
    Key(
        [ALT, SHIFT],
        "n",
        lazy.layoutuffle_down(),
        desc="Move windows down in current stack",
    ),
    Key(
        [ALT, SHIFT],
        "e",
        lazy.layoutuffle_up(),
        desc="Move windows up in current stack",
    ),
    Key(
        [ALT, SHIFT],
        "period",
        lazy.layout.increase_nmaster(),
        desc="increase number in master pane (Tile)",
    ),
    Key(
        [ALT, SHIFT],
        "comma",
        lazy.layout.decrease_nmaster(),
        desc="decrease number in master pane (Tile)",
    ),
    Key(
        [ALT],
        "period",
        lazy.layout.grow(),
        lazy.layout.increase_ratio().when(layout=["Tile"]),
        desc="increase number in master pane (Tile)",
    ),
    Key(
        [ALT],
        "comma",
        lazy.layoutrink(),
        lazy.layout.decrease_ratio().when(layout=["Tile"]),
        desc="decrease number in master pane (Tile)",
    ),
    Key(
        [ALT],
        "k",
        lazy.layout.normalize(),
        desc="normalize window size ratios",
    ),
    Key(
        [ALT],
        "m",
        lazy.layout.maximize(),
        desc="toggle window between minimum and maximum sizes",
    ),
    Key(
        [WIN, CONTROL],
        "m",
        lazy.window.toggle_fullscreen(),
        desc="toggle fullscreen",
    ),
    # Group controls
    Key(
        [WIN],
        "tab",
        lazy.screen.next_group(),
        desc="navigate to next group",
    ),
    Key(
        [WIN, SHIFT],
        "tab",
        lazy.screen.prev_group(),
        desc="navigate to previous group",
    ),
    # Stack controls
    Key(
        [ALT, SHIFT],
        "space",
        lazy.layout.flip(),
        desc="Switch which side main pane occupies (XmonadTall)",
    ),
    Key(
        [ALT, CONTROL],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    # Volume control
    Key(
        [WIN],
        "c",
        lazy.spawn(SOUND_CMD),
        lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
        lazy.spawn(notify_cmd("Toggle mute")),
        desc="Toggle mute/unmute",
    ),
    Key(
        [WIN],
        "z",
        lazy.spawn(SOUND_CMD),
        lazy.spawn("amixer set Master 3%-"),
        lazy.spawn("pactl set-sink-volume 0 -3%"),
        desc="Decrease volume",
    ),
    Key(
        [WIN],
        "x",
        lazy.spawn(SOUND_CMD),
        lazy.spawn("amixer set Master 3%+"),
        lazy.spawn("pactl set-sink-volume 0 +3%"),
        desc="Increase volume",
    ),
    Key(
        [WIN, SHIFT],
        "3",
        lazy.spawn(SOUND_CMD),
        lazy.spawn("sh " + QTILE_DIR + "/.init-scripts/toggle-touchpad 0"),
        desc="disable touchpad",
    ),
    Key(
        [WIN],
        "3",
        lazy.spawn(SOUND_CMD),
        lazy.spawn("sh " + QTILE_DIR + "/.init-scripts/toggle-touchpad 1"),
        desc="enable touchpad",
    ),
    # Brightness control
    # monitor #1
    Key(
        [WIN],
        "1",
        lazy.spawn(SOUND_CMD),
        lazy.spawn(QTILE_DIR + "/.init-scripts/brightness inc 0"),
        desc="Increase brightness",
    ),
    Key(
        [WIN, SHIFT],
        "1",
        lazy.spawn(SOUND_CMD),
        lazy.spawn(QTILE_DIR + "/.init-scripts/brightness des 0"),
        desc="Decrease brightness",
    ),
    Key(
        [WIN, CONTROL],
        "1",
        lazy.spawn(SOUND_CMD),
        lazy.spawn(QTILE_DIR + "/.init-scripts/brightness dim 0"),
        desc="Dim screen",
    ),
    # monitor #2
    Key(
        [WIN],
        "2",
        lazy.spawn(SOUND_CMD),
        lazy.spawn(QTILE_DIR + "/.init-scripts/brightness inc 1"),
        desc="Increase brightness",
    ),
    Key(
        [WIN, SHIFT],
        "2",
        lazy.spawn(SOUND_CMD),
        lazy.spawn(QTILE_DIR + "/.init-scripts/brightness des 1"),
        desc="Decrease brightness",
    ),
    Key(
        [WIN, CONTROL],
        "2",
        lazy.spawn(SOUND_CMD),
        lazy.spawn(QTILE_DIR + "/.init-scripts/brightness dim 1"),
        desc="Dim screen",
    ),
    # Power control
    Key(
        [WIN],
        "q",
        lazy.spawn("systemctl suspend"),
        desc="Suspend",
    ),
    Key(
        [WIN],
        "Escape",
        lazy.spawn("/usr/bin/zsh " + QTILE_DIR + "/.init-scripts/power-v2"),
        desc="Power management",
    ),
    # Keyboard layout control
    Key(
        [WIN],
        "a",
        lazy.spawn(SOUND_CMD),
        lazy.spawn(QTILE_DIR + "/.init-scripts/keyboard-layout"),
        desc="Switch keyboard layout",
    ),
    # Cursor visibility control
    Key(
        [WIN],
        "s",
        lazy.spawn(SOUND_CMD),
        lazy.spawn(QTILE_DIR + "/.init-scripts/toggle-xbanish"),
        desc="Switch cursor visibility",
    ),
    # Input method control
    Key(
        [WIN],
        "space",
        lazy.spawn(SOUND_CMD),
        lazy.spawn(QTILE_DIR + "/.init-scripts/ibus-switch-input"),
        desc="Switch input method",
    ),
]

for i, (group_name, kwargs) in enumerate(group_names, 1):
    keys.append(
        Key(
            [WIN],
            group_keys[str(i)],
            lazy.group[group_name].toscreen(),
        )
    )

    keys.append(
        Key(
            [WIN, CONTROL],
            group_keys[str(i)],
            lazy.window.togroup(group_name),
        )
    )
