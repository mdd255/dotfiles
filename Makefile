# =============================================================================
# Dotfiles Installation Makefile
# =============================================================================

# Variables
DOTFILES_DIR := ~/.config/dotfiles
USER := $(shell whoami)
HOME_DIR := $(HOME)
APPS_DIR := ~/Apps

# URLs
OMZ_INSTALL_URL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
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
.PHONY: install-deps install-zsh install-nvim create-links install-packages
.PHONY: deps-dco deps-media deps-docker
.PHONY: clean-post

help: ## Show this help message
	@echo "Dotfiles Installation Makefile"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: check-deps install-packages install-deps install-zsh install-nvim create-links clean-post ## Full installation
	@echo "✅ Installation completed successfully!"

uninstall: ## Remove installed configurations (keeps packages)
	rm -rf ~/.oh-my-zsh ~/.zshrc
	rm -rf ~/.config/zsh
	rm -f ~/.{wezterm.lua,p10k.zsh} ~/.cargo/env
	@echo "✅ Configurations removed"

clean: clean-post ## Clean temporary files

check-deps: ## Check for required dependencies
	@command -v pacman >/dev/null || (echo "❌ pacman not found" && exit 1)
	@command -v yay >/dev/null || (echo "❌ yay not found - install it first" && exit 1)
	@command -v git >/dev/null || (echo "❌ git not found" && exit 1)
	@command -v curl >/dev/null || (echo "❌ curl not found" && exit 1)
	@echo "✅ All dependencies found"

# =============================================================================
# Post Clean
# =============================================================================

clean-post: ## Remove temporary directories
	rm -rf ~/.config/zsh/zsh

# =============================================================================
# Dependencies Installation
# =============================================================================

install-deps: deps-dco deps-media deps-docker ## Install all dependencies

install-packages: ## Install all packages tracked in the packages file
	$(call install_yay_packages,$$(cat $(DOTFILES_DIR)/packages))

deps-dco: ## Install Docker Color Output
	@echo "🔧 Installing Docker Color Output..."
	mkdir -p $(APPS_DIR)
	rm -rf $(APPS_DIR)/docker-color-output
	git clone $(DCO_REPO) $(APPS_DIR)/docker-color-output
	$(MAKE) build -C $(APPS_DIR)/docker-color-output
	$(call create_sudo_symlink,$(APPS_DIR)/docker-color-output/bin/docker-color-output,/usr/bin/docker-color-output)

deps-media: ## Enable media and bluetooth services
	@echo "🔧 Configuring media services..."
	$(call enable_service,bluetooth.service)

deps-docker: ## Setup Docker service and user permissions
	@echo "🔧 Configuring Docker..."
	$(call enable_service,docker.service)
	$(call enable_service,containerd.service)
	sudo groupadd -f docker
	sudo usermod -aG docker $(USER)
	@echo "📝 You may need to log out and back in for Docker permissions to take effect"

# =============================================================================
# Application Installation
# =============================================================================

install-zsh: install-packages ## Install and configure Zsh with Oh My Zsh
	@echo "🔧 Installing Zsh and Oh My Zsh..."
	rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zshenv
	curl -fsSL $(OMZ_INSTALL_URL) | bash
	git clone $(ZSH_AUTOSUGGESTIONS_REPO) ~/.oh-my-zsh/plugins/zsh-autosuggestions
	git clone $(ZSH_HIGHLIGHTING_REPO) ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
	git clone --depth=1 $(POWERLEVEL10K_REPO) ~/.oh-my-zsh/themes/powerlevel10k
	$(call create_symlink,$(DOTFILES_DIR)/zsh/.zshrc,~/.zshrc)
	$(call create_symlink,$(DOTFILES_DIR)/zsh/.zsh_env,~/.zshenv)
	mkdir -p ~/.cargo
	$(call create_symlink,$(DOTFILES_DIR)/zsh/.zshenv,~/.cargo/env)
	$(call create_symlink,$(DOTFILES_DIR)/zsh/.p10k.zsh,~/.p10k.zsh)

install-nvim: ## Neovim post-install notes
	@echo "📝 Note: You may need to manually link neovim-ruby-host based on your Ruby version"

# =============================================================================
# Configuration Linking
# =============================================================================

create-links: ## Create all configuration symlinks
	@echo "🔗 Creating configuration symlinks..."
	$(call create_symlink,$(DOTFILES_DIR)/.wezterm.lua,~/.wezterm.lua)
	$(call create_symlink,$(DOTFILES_DIR)/zsh,~/.config/zsh)
	$(call create_symlink,$(DOTFILES_DIR)/lazyvim,~/.config/nvim)
	$(call create_symlink,$(DOTFILES_DIR)/lazygit,~/.config/lazygit/config.yml)
	$(call create_symlink,$(DOTFILES_DIR)/claude/CLAUDE.md,~/.claude/CLAUDE.md)
	$(call create_symlink,$(DOTFILES_DIR)/claude/settings.json,~/.claude/settings.json)
	$(call create_symlink,$(DOTFILES_DIR)/claude/statusline-command.sh,~/.claude/statusline-command.sh)
	$(call create_symlink,$(DOTFILES_DIR)/claude/hooks,~/.claude/hooks)
	$(call create_symlink,$(DOTFILES_DIR)/claude/skills,~/.claude/skills)

surfing-keys: ## Build SurfingKeys configuration
	@echo "🔨 Building SurfingKeys configuration..."
	@cd $(DOTFILES_DIR)/surfing-keys && make build

# =============================================================================
