from libqtile import widget, bar
from os import popen
from libqtile.config import Screen

FONT = "FiraCode Nerd Font Mono"
TEXT_FONT_SIZE = 13
ICON_SIZE = 14
LARGE_ICON_SIZE = 22
BAR_HEIGHT = 20

colors = ["#0a0a0a", "#61afef", "#e5c07b", "#abb2bf", "#ef596f"]

# DEFAULT WIDGET SETTINGS #####
widget_defaults = {
    "font": "FiraCode Nerd Font Mono 12",
    "fontsize": TEXT_FONT_SIZE,
    "padding": 5,
    "background": colors[0],
    "foreground": colors[1],
    "margin_y": 2,
}

extension_defaults = widget_defaults.copy()


def shorten_window_name(win_name_str):
    if len(win_name_str) < 30:
        return win_name_str

    win_name_sep = "-"
    alter_win_name_sep = "|"
    raw_win_names = [win_name_str]
    win_names = []
    win_name_str = ""

    for win_name in raw_win_names:
        win_name = win_name.split(win_name_sep)[-1]
        win_name = win_name.split(alter_win_name_sep)[-1].lower().strip()

        win_names.append(win_name)
    return "".join(win_names)


def init_widgets_list():
    """Status bar config."""
    left_widgets = [
        widget.Sep(
            padding=10,
            background=colors[0],
            foreground=colors[0],
        ),
        widget.CurrentScreen(
            fontsize=LARGE_ICON_SIZE,
            active_text="󰣇",
            active_color=colors[4],
            inactive_text="󰣇",
            inactive_color=colors[3],
            background=colors[0],
        ),
        widget.Sep(
            padding=20,
            background=colors[0],
            foreground=colors[0],
        ),
        widget.GroupBox(
            fontsize=LARGE_ICON_SIZE,
            background=colors[0],
            active=colors[1],
            inactive=colors[3],
            rounded=True,
            hide_unused=True,
            highlight_color=colors[2],
            highlight_method="block",
            block_highlight_text_color=colors[4],
            mouse_callbacks={"Button1": lambda: None},
            font=FONT,
        ),
        widget.Sep(
            padding=90,
            background=colors[0],
            foreground=colors[0],
        ),
    ]

    mid_widgets = [
        widget.TaskList(
            background=colors[0],
            fontsize=13,
            icon_size=0,
            font=FONT,
            margin_y=0,
            padding_y=2,
            mouse_callbacks={"Button1": lambda: None},
            parse_text=shorten_window_name,
            highlight_method="block",
        ),
    ]

    right_widgets = [
        widget.Net(
            fontsize=TEXT_FONT_SIZE,
            format="{down:.0f}{down_suffix:<2}",
            foreground=colors[1],
            background=colors[0],
            padding=10,
            use_bits=False,
            update_interval=21,
        ),
        widget.Battery(
            fontsize=TEXT_FONT_SIZE,
            padding=10,
            discharge_char="󰁾 ",
            charge_char="󰂄 ",
            full_char="󰁹 ",
            unknown_char="󰂃 ",
            update_interval=50,
            format="{char}{percent:2.0%}",
            foreground=colors[1],
            background=colors[0],
        ),
        widget.Volume(
            fmt="󰂚 {} ",
            mute_format="󰟢",
            channel="Master",
            foreground=colors[1],
            background=colors[0],
            mouse_callbacks={"Button1": lambda: None},
            update_interval=5,
            padding=10,
        ),
        widget.Clock(
            fontsize=TEXT_FONT_SIZE,
            update_interval=61,
            format="%a %m-%d %H:%M ",
            foreground=colors[1],
            background=colors[0],
            padding=10,
        ),
        widget.KeyboardLayout(
            fontsize=LARGE_ICON_SIZE,
            configured_keyboards=[
                "us colemak",
                "us intl",
            ],
            display_map={
                "us colemak": "",
                "us intl": "",
            },
            mouse_callbacks={"Button1": lambda: None},
        ),
        widget.Sep(
            padding=10,
            background=colors[0],
            foreground=colors[0],
        ),
    ]

    # remove battery widget if there is no battery
    check_batt_cmd = popen("ls /sys/class/power_supply")
    check_batt_output = check_batt_cmd.read()

    if len(check_batt_output) == 0:
        right_widgets[2] = (
            widget.Sep(
                padding=10,
                background=colors[1],
                foreground=colors[1],
            ),
        )

    return left_widgets + mid_widgets + right_widgets


def init_widgets_screen1():
    """Status bar for screen #1."""
    widgets = init_widgets_list()
    return widgets


def init_widgets_screen2():
    """Status bar for screen #2."""
    widgets = init_widgets_list()
    return widgets


def init_widgets_screen3():
    """Status bar for screen #3."""
    widgets = init_widgets_list()
    return widgets


def init_screens():
    """Apply status bars."""
    return [
        Screen(
            top=bar.Bar(widgets=init_widgets_screen1(), opacity=1.0, size=BAR_HEIGHT),
        ),
        Screen(
            top=bar.Bar(widgets=init_widgets_screen2(), opacity=1.0, size=BAR_HEIGHT),
        ),
        Screen(
            top=bar.Bar(widgets=init_widgets_screen3(), opacity=1.0, size=BAR_HEIGHT),
        ),
    ]
