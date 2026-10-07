-- Extra env variables. NVIDIA vars now come from Omarchy's default.hypr.nvidia.
hl.env("TERMINAL", "kitty")
hl.env("BROWSER", "brave")
hl.env("EDITOR", "neovide")
hl.env("SHELL", "/usr/bin/zsh")
hl.env("XCURSOR_SIZE", "21")

-- Load secret environment variables into Hyprland for GUI apps (e.g. Neovide).
o.exec_on_start([[bash -c 'source /home/dh/.config/secret-env && grep "^export " /home/dh/.config/secret-env | sed "s/^export //" | while IFS= read -r line; do key="${line%%=*}"; eval "val=\$$key"; hyprctl keyword env "$key,$val"; done']])
