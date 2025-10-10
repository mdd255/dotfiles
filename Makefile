# =============================================================================
# Dotfiles Installation Makefile
# =============================================================================

# Variables
DOTFILES_DIR := ~/.config/dotfiles
USER := $(shell whoami)
HOME_DIR := $(HOME)
XORG_CONF_DIR := /etc/X11/xorg.conf.d
APPS_DIR := ~/Apps

Package lists
PACMAN_CORE := xclip git-delta eza jq postgresql-libs btop ibus go xorg-xev zip
PACMAN_TOOLS := fzf fd bat dunst ttf-firacode-nerd unzip maim python-pip
PACMAN_MEDIA := pavucontrol bluez bluez-utils blueman
PACMAN_DOCKER := docker docker-compose
PACMAN_QTILE := rofi qtile python-iwlib python-psutil i3lock ly
PACMAN_NVIM := neovim ruby python-pynvim lazygit github-cli neovide
YAY_PACKAGES := xbanish wezterm pyenv pyenv-virtualenv biome cursor-bin

# URLs
OMZ_INSTALL_URL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
FNM_INSTALL_URL := https://fnm.vercel.app/install
ZSH_AUTOSUGGESTIONS_REPO := https://github.com/zsh-users/zsh-autosuggestions
ZSH_HIGHLIGHTING_REPO := https://github.com/zsh-users/zsh-syntax-highlighting.git
POWERLEVEL10K_REPO := https://github.com/romkatv/powerlevel10k.git
DCO_REPO := https://github.com/devemio/docker-color-output.git

# Helper functions
define install_pacman_packages
	@echo "Installing pacman packages: $(1)"
	sudo pacman -S --needed --noconfirm $(1)
endef

define install_yay_packages
	@echo "Installing AUR packages: $(1)"
	yay -S --needed --noconfirm $(1)
endef

define create_symlink
	@echo "Creating symlink: $(2) -> $(1)"
	rm -rf $(2)
	ln -fs $(1) $(2)
endef

define create_sudo_symlink
	@echo "Creating system symlink: $(2) -> $(1)"
	sudo ln -fs $(1) $(2)
endef

define enable_service
	@echo "Enabling and starting service: $(1)"
	sudo systemctl enable $(1)
	sudo systemctl restart $(1)
endef

# =============================================================================
# Main Targets
# =============================================================================

.PHONY: help install uninstall clean check-deps surfing-keys
.PHONY: install-deps install-zsh install-qtile install-nvim create-links
.PHONY: deps-core deps-fnm deps-dco deps-screenshot deps-media deps-docker
.PHONY: clean-pre clean-post

help: ## Show this help message
	@echo "Dotfiles Installation Makefile"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: check-deps clean-pre install-deps install-zsh install-qtile install-nvim create-links clean-post ## Full installation
	@echo "✅ Installation completed successfully!"

uninstall: ## Remove installed configurations (keeps packages)
	rm -rf ~/.oh-my-zsh ~/.zshrc ~/.fnm ~/.local/share/fnm
	rm -rf ~/.config/{qtile,zsh,rofi,dunst}
	rm -f ~/.{wezterm.lua,p10k.zsh} ~/.cargo/env
	@echo "✅ Configurations removed"

clean: clean-pre clean-post ## Clean temporary files

check-deps: ## Check for required dependencies
	@command -v pacman >/dev/null || (echo "❌ pacman not found" && exit 1)
	@command -v yay >/dev/null || (echo "❌ yay not found - install it first" && exit 1)
	@command -v git >/dev/null || (echo "❌ git not found" && exit 1)
	@command -v curl >/dev/null || (echo "❌ curl not found" && exit 1)
	@echo "✅ All dependencies found"

# =============================================================================
# Pre/Post Clean
# =============================================================================

clean-pre: ## Setup X11 configurations
	$(call create_sudo_symlink,$(DOTFILES_DIR)/10-disable-touch.conf,$(XORG_CONF_DIR)/10-disable-touch.conf)
	$(call create_sudo_symlink,$(DOTFILES_DIR)/20-keyboard-layout.conf,$(XORG_CONF_DIR)/20-keyboard-layout.conf)
	$(call create_sudo_symlink,$(DOTFILES_DIR)/30-touchpad-touch.conf,$(XORG_CONF_DIR)/30-touchpad-touch.conf)

clean-post: ## Remove temporary directories
	rm -rf ~/.config/qtile/qtile ~/.config/zsh/zsh ~/.config/rofi/rofi ~/.config/dunst/dunst

# =============================================================================
# Dependencies Installation
# =============================================================================

install-deps: deps-core deps-fnm deps-dco deps-screenshot deps-media deps-docker ## Install all dependencies

deps-core: ## Install core system packages
	$(call install_pacman_packages,$(PACMAN_CORE) $(PACMAN_TOOLS))
	$(call install_yay_packages,$(YAY_PACKAGES))

deps-fnm: ## Install Fast Node Manager and Node.js tools
	@echo "🔧 Installing FNM and Node.js tools..."
	rm -rf ~/.fnm ~/.local/share/fnm
	$(call install_pacman_packages,unzip)
	curl -fsSL $(FNM_INSTALL_URL) | bash
	@echo "📝 Manual steps required:"
	@echo "   1. Restart your shell"
	@echo "   2. Run: fnm install 20"
	@echo "   3. Run: npm i -g @commitlint/{cli,config-conventional} yarn pnpm tsx"
	@echo "   4. Create: echo \"module.exports = {extends: ['@commitlint/config-conventional']}\" > ~/commitlint.config.js"

deps-dco: ## Install Docker Color Output
	@echo "🔧 Installing Docker Color Output..."
	mkdir -p $(APPS_DIR)
	rm -rf $(APPS_DIR)/docker-color-output
	git clone $(DCO_REPO) $(APPS_DIR)/docker-color-output
	$(MAKE) build -C $(APPS_DIR)/docker-color-output
	$(call create_sudo_symlink,$(APPS_DIR)/docker-color-output/bin/docker-color-output,/usr/bin/docker-color-output)

deps-screenshot: ## Install screenshot tools
	@echo "🔧 Installing screenshot tools..."
	$(call install_pacman_packages,maim python-pip)
	$(call create_sudo_symlink,$(HOME_DIR)/.config/qtile/.init-scripts/screenshot,/usr/bin/screenshot)
	$(call create_sudo_symlink,$(HOME_DIR)/.config/qtile/.init-scripts/screenshot-all,/usr/bin/screenshot-all)

deps-media: ## Install media and bluetooth packages
	@echo "🔧 Installing media packages..."
	$(call install_pacman_packages,$(PACMAN_MEDIA))
	$(call enable_service,bluetooth.service)

deps-docker: ## Install Docker and setup user permissions
	@echo "🔧 Installing Docker..."
	$(call install_pacman_packages,$(PACMAN_DOCKER))
	$(call enable_service,docker.service)
	$(call enable_service,containerd.service)
	sudo groupadd -f docker
	sudo usermod -aG docker $(USER)
	@echo "📝 You may need to log out and back in for Docker permissions to take effect"

# =============================================================================
# Application Installation
# =============================================================================

install-zsh: deps-core ## Install and configure Zsh with Oh My Zsh
	@echo "🔧 Installing Zsh and Oh My Zsh..."
	rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zshenv
	$(call install_pacman_packages,zsh)
	curl -fsSL $(OMZ_INSTALL_URL) | bash
	git clone $(ZSH_AUTOSUGGESTIONS_REPO) ~/.oh-my-zsh/plugins/zsh-autosuggestions
	git clone $(ZSH_HIGHLIGHTING_REPO) ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
	git clone --depth=1 $(POWERLEVEL10K_REPO) ~/.oh-my-zsh/themes/powerlevel10k
	$(call create_symlink,$(DOTFILES_DIR)/zsh/.zshrc,~/.zshrc)
	$(call create_symlink,$(DOTFILES_DIR)/zsh/.zsh_env,~/.zshenv)
	mkdir -p ~/.cargo
	$(call create_symlink,$(DOTFILES_DIR)/zsh/.zshenv,~/.cargo/env)
	$(call create_symlink,$(DOTFILES_DIR)/zsh/.p10k.zsh,~/.p10k.zsh)

install-qtile: ## Install Qtile window manager
	@echo "🔧 Installing Qtile..."
	$(call install_pacman_packages,$(PACMAN_QTILE))
	sudo rm -rf ~/.config/qtile

install-nvim: ## Install Neovim and dependencies
	@echo "🔧 Installing Neovim..."
	$(call install_pacman_packages,$(PACMAN_NVIM))
	@echo "📝 Note: You may need to manually link neovim-ruby-host based on your Ruby version"

# =============================================================================
# Configuration Linking
# =============================================================================

create-links: ## Create all configuration symlinks
	@echo "🔗 Creating configuration symlinks..."
	$(call create_symlink,$(DOTFILES_DIR)/.wezterm.lua,~/.wezterm.lua)
	$(call create_symlink,$(DOTFILES_DIR)/zsh,~/.config/zsh)
	$(call create_symlink,$(DOTFILES_DIR)/qtile,~/.config/qtile)
	$(call create_symlink,$(DOTFILES_DIR)/rofi,~/.config/rofi)
	$(call create_symlink,$(DOTFILES_DIR)/dunst,~/.config/dunst)
	tsx $(DOTFILES_DIR)/Code/split-configs/sync.ts
	$(call create_symlink,$(DOTFILES_DIR)/Code/User/settings.json,~/.config/Code/User/settings.json)
	$(call create_symlink,$(DOTFILES_DIR)/Code/User/keybindings.json,~/.config/Code/User/keybindings.json)
	$(call create_symlink,$(DOTFILES_DIR)/Code/User/settings.json,~/.config/Cursor/User/settings.json)
	$(call create_symlink,$(DOTFILES_DIR)/Code/User/keybindings.json,~/.config/Cursor/User/keybindings.json)
	$(call create_symlink,$(DOTFILES_DIR)/Code/User/snippets,~/.config/Code/User)
	$(call create_sudo_symlink,$(DOTFILES_DIR)/us,/usr/share/X11/xkb/symbols/us)
	$(call create_symlink,$(DOTFILES_DIR)/Code/vscode-nvim,~/.config/vscode-nvim)
	$(call create_symlink,$(DOTFILES_DIR)/lazyvim,~/.config/nvim)
	$(call create_symlink,$(DOTFILES_DIR)/lazygit,~/.config/lazygit/config.yml)

surfing-keys: ## Build SurfingKeys configuration
	@echo "🔨 Building SurfingKeys configuration..."
	@cd $(DOTFILES_DIR)/surfing-keys && make build

# =============================================================================
