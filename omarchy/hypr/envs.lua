-- Extra env variables. NVIDIA vars now come from Omarchy's default.hypr.nvidia.
hl.env("TERMINAL", "kitty")
hl.env("BROWSER", "brave")
hl.env("EDITOR", "neovide")
hl.env("SHELL", "/usr/bin/zsh")
hl.env("XCURSOR_SIZE", "21")

-- Load secret environment variables into Hyprland for GUI apps (e.g. Neovide).
local secret_env = (os.getenv("HOME") or "") .. "/.config/secret-env"

o.exec_on_start(string.format(
	[[bash -c '[ -f "%s" ] || exit 0; source "%s" && grep "^export " "%s" | sed "s/^export //" | while IFS= read -r line; do key="${line%%%%=*}"; eval "val=\$$key"; hyprctl keyword env "$key,$val"; done']],
	secret_env, secret_env, secret_env
))
