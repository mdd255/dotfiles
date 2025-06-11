install:
		make clean.pre
		make install.deps
		make install.zsh
		make install.qtile
		make install.nvim
		make links
		make clean.post

clean.pre:
	sudo ln -fs ~/.config/dotfiles/10-disable-touch.conf /etc/X11/xorg.conf.d/10-disable-touch.conf
	sudo ln -fs ~/.config/dotfiles/20-keyboard-layout.conf /etc/X11/xorg.conf.d/20-keyboard-layout.conf
	sudo ln -fs ~/.config/dotfiles/30-touchpad-touch.conf /etc/X11/xorg.conf.d/30-touchpad-touch.conf

clean.post:
	rm -rf ~/.config/qtile/qtile
	rm -rf ~/.config/zsh/zsh
	rm -rf ~/.config/rofi/rofi

install.zsh:
	rm -rf ~/.oh-my-zsh
	rm -f ~/.zshrc
	sudo pacman -S --needed --noconfirm zsh
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k
	sudo ln -sf ~/.config/dotfiles/zsh/.zshrc ~/.zshrc
	mkdir -p ~/.cargo
	sudo ln -sf ~/.config/dotfiles/zsh/.zshenv ~/.cargo/env
	sudo ln -sf ~/.config/dotfiles/zsh/.p10k.zsh ~/.p10k.zsh

install.deps:
	make deps.misc
	make deps.fnm
	make deps.dco
	make deps.screenshot
	make deps.media
	make deps.docker

deps.fnm:
	rm -rf ~/.fnm
	rm -rf ~/.local/share/fnm
	sudo pacman -S --needed --noconfirm unzip
	curl -fsSL https://fnm.vercel.app/install | bash
	source ~/.bashrc
	fnm install 20
	npm i -g @commitlint/{cli,config-conventional}
	npm install -g yarn pnpm tsx
	echo "module.exports = {extends: ['@commitlint/config-conventional']}" > ~/commitlint.config.js

deps.dco:
	mkdir -p ~/Apps
	rm -rf ~/Apps/docker-color-output
	git clone https://github.com/devemio/docker-color-output.git ~/Apps/docker-color-output
	make build -C ~/Apps/docker-color-output
	sudo ln -fs ~/Apps/docker-color-output/bin/docker-color-output /usr/bin/docker-color-output

deps.screenshot:
	sudo pacman -S --needed --noconfirm maim python-pip
	sudo ln -fs ${HOME}/.config/qtile/.init-scripts/screenshot.sh /usr/bin/screenshot
	sudo ln -fs ${HOME}/.config/qtile/.init-scripts/screenshot-all.sh /usr/bin/screenshot-all

deps.media:
	sudo pacman -S --needed --noconfirm pavucontrol bluez bluez-utils blueman 
	sudo systemctl enable bluetooth.service
	sudo systemctl restart bluetooth.service

deps.misc:
	sudo pacman -S --needed --noconfirm xclip git-delta eza jq postgresql-libs
	sudo pacman -S --needed --noconfirm btop ibus go xorg-xev zip
	sudo pacman -S --needed --noconfirm fzf fd bat dunst ttf-firacode-nerd
	yay -S --needed --noconfirm xbanish wezterm pyenv pyenv-virtualenv visual-studio-code-bin biome

deps.docker:
	sudo pacman -S --needed --noconfirm docker docker-compose
	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service
	sudo systemctl restart docker.service
	sudo systemctl restart containerd.service
	sudo groupadd -f docker
	sudo usermod -aG docker $user

install.qtile:
	make qtile.deps

qtile.deps:
	sudo pacman -S --needed --noconfirm rofi qtile python-iwlib python-psutil i3lock
	sudo rm -rf ~/.config/qtile

install.nvim:
	make nvim.deps

nvim.deps:
	sudo pacman -S --needed --noconfirm neovim ruby python-pynvim
	sudo ln -fs ~/.local/share/gem/ruby/3.0.0/bin/neovim-ruby-host /usr/bin/neovim-ruby-host

links:
	sudo ln -fs ~/.config/dotfiles/.wezterm.lua ~/.wezterm.lua
	sudo ln -fs ~/.config/dotfiles/zsh ~/.config/zsh
	sudo ln -fs ~/.config/dotfiles/qtile ~/.config/qtile
	sudo ln -fs ~/.config/dotfiles/rofi ~/.config/rofi
	sudo ln -fs ~/.config/dotfiles/.wezterm.lua ~/.wezterm.lua
	tsx ~/.config/dotfiles/Code/split-configs/sync.ts
	sudo ln -fs ~/.config/dotfiles/Code/User/settings.json ~/.config/Code/User/settings.json
	sudo ln -fs ~/.config/dotfiles/Code/User/keybindings.json ~/.config/Code/User/keybindings.json
	sudo ln -fs ~/.config/dotfiles/Code/snippets ~/.config/Code/User/snippets
	sudo ln -fs ~/.config/dotfiles/us /usr/share/X11/xkb/symbols/us
	sudo ln -fs ~/.config/dotfiles/Code/vscode-nvim ~/.config/nvim
