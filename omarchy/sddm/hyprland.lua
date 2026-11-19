-- SDDM greeter compositor config: stock Omarchy greeter config + the user's monitor layout.
-- Reads the dotfiles monitors.lua directly (single source of truth). The sddm user
-- needs traverse (x) permission on /home/dh -- see `make setup-sddm-monitors`.
dofile("/usr/share/sddm/hyprland.lua")
dofile("/home/dh/.config/dotfiles/omarchy/hypr/monitors.lua")
