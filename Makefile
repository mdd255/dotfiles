# =============================================================================
# Dotfiles Installation Makefile
# =============================================================================

DOTFILES_DIR := $(HOME)/.config/dotfiles
APPS_DIR     := $(HOME)/Apps

OMZ_INSTALL_URL    := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
POWERLEVEL10K_REPO := https://github.com/romkatv/powerlevel10k.git
DCO_REPO           := https://github.com/devemio/docker-color-output.git

# link <src> <dest>: symlink dest to src; a real file/dir at dest is moved to dest.bak.<ts>
define link
	mkdir -p $$(dirname $(2))
	@if [ -e $(2) ] && [ ! -L $(2) ]; then mv $(2) $(2).bak.$$(date +%s); fi
	ln -sfn $(1) $(2)
endef

# enable_service <services...>: enable and (re)start services
define enable_service
	sudo systemctl enable $(1)
	sudo systemctl restart $(1)
endef

# Steps in `install` depend on order
.NOTPARALLEL:

.PHONY: help install install-packs install-dco \
	setup-docker install-zsh setup-nvim setup-omarchy \
	setup-tools setup-keyboard setup-sddm update-vimium

help: ## Show this help message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# =============================================================================
# Packages & services
# =============================================================================

install-packs: ## Install all packages tracked in the packages file
	yay -S --needed --noconfirm $$(cat $(DOTFILES_DIR)/essential-packages)

install-dco: ## Install Docker Color Output
	mkdir -p $(APPS_DIR)
	if [ -d $(APPS_DIR)/docker-color-output/.git ]; then \
		git -C $(APPS_DIR)/docker-color-output pull --ff-only; \
	else \
		rm -rf $(APPS_DIR)/docker-color-output; \
		git clone $(DCO_REPO) $(APPS_DIR)/docker-color-output; \
	fi
	$(MAKE) build -C $(APPS_DIR)/docker-color-output
	sudo ln -fs $(APPS_DIR)/docker-color-output/bin/docker-color-output /usr/bin/docker-color-output

setup-docker: ## Setup Docker service and user permissions
	$(call enable_service,docker.service containerd.service)
	sudo groupadd -f docker
	sudo usermod -aG docker $$(whoami)
	@echo "📝 Log out and back in for Docker permissions to take effect"

# =============================================================================
# Configs
# =============================================================================

install-zsh: ## Install Oh My Zsh + p10k and link zsh configs
	rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zshenv
	curl -fsSL $(OMZ_INSTALL_URL) | RUNZSH=no CHSH=no KEEP_ZSHRC=yes bash
	git clone --depth=1 $(POWERLEVEL10K_REPO) ~/.oh-my-zsh/themes/powerlevel10k
	$(call link,$(DOTFILES_DIR)/zsh/.zshrc,~/.zshrc)
	$(call link,$(DOTFILES_DIR)/zsh/.zsh_env,~/.zshenv)
	$(call link,$(DOTFILES_DIR)/zsh/.p10k.zsh,~/.p10k.zsh)
	sudo chsh -s /usr/bin/zsh $$(whoami)

setup-nvim: ## Link LazyVim config
	$(call link,$(DOTFILES_DIR)/lazyvim,~/.config/nvim)

setup-omarchy: ## Link Omarchy shell and Hyprland configs
	$(call link,$(DOTFILES_DIR)/omarchy/shell.json,~/.config/omarchy/shell.json)
	$(call link,$(DOTFILES_DIR)/omarchy/shell.toml,~/.config/omarchy/shell.toml)
	$(call link,$(DOTFILES_DIR)/omarchy/hypr,~/.config/hypr)

setup-tools: ## Link wezterm, kitty and Claude configs
	$(call link,$(DOTFILES_DIR)/.wezterm.lua,~/.wezterm.lua)
	mkdir -p ~/.claude ~/.config/kitty
	$(call link,$(DOTFILES_DIR)/kitty/kitty.conf,~/.config/kitty/kitty.conf)
	for f in CLAUDE.md settings.json statusline-command.sh hooks skills; do \
		rm -rf ~/.claude/$$f; ln -s $(DOTFILES_DIR)/claude/$$f ~/.claude/$$f; \
	done

setup-keyboard: ## Set Colemak for the TTY / login screen (SDDM reads XKB vars from vconsole.conf)
	sudo localectl set-keymap colemak
	sudo localectl --no-convert set-x11-keymap us "" colemak

setup-sddm: ## Make the SDDM login screen read the dotfiles monitors.lua
	sudo setfacl -m u:sddm:x ~
	sudo install -Dm644 $(DOTFILES_DIR)/omarchy/sddm/hyprland.lua /etc/sddm/hyprland.lua
	sudo install -d /etc/sddm.conf.d
	printf '[Wayland]\nCompositorCommand=start-hyprland -- --config /etc/sddm/hyprland.lua\n' \
		| sudo tee /etc/sddm.conf.d/20-dh-monitors.conf >/dev/null

update-vimium: ## Update vimium configuration
	node $(DOTFILES_DIR)/vimium/update-config

install: install-packs install-dco install-zsh setup-docker setup-nvim setup-omarchy setup-tools setup-keyboard setup-sddm update-vimium
