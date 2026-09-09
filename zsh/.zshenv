# sys envs
export LANG=en_US.UTF-8
export LC_ALL="en_US.UTF-8"
export ARCHFLAGS="-arch x86_64"
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=/usr/bin/brave

# docker
export DOCKER_BUILDKIT=1

# node
export NODE_OPTIONS=--max-old-space-size=6144

# go envs
export GOPATH=$HOME/go

# bat envs
export BAT_THEME="Dracula"

# fzf envs
export FZF_DEFAULT_OPTS="--preview-window 'right:50%' \
  --layout reverse \
  --with-nth=-1 \
  --margin=1,4 \
  --preview 'bat --color=always --style=header,grid --line-range :300 {}'"

export FZF_SEARCH_PATHS="$HOME/Projects $HOME/.config $HOME/Downloads $HOME/Apps $HOME/Documents"

_fzf_ignore_names=(
  .git build dist node_modules .next .gk .pyenv .ssh .biome yay .electron-gyp
  .swt .password-store .screenlayout .aws .yarn .vim package-lock.json .idea
  .eclipse skypeforlinux "MongoDB Compass" .mongoDB libreoffice Postman .npm
  virtualenvs BraveSoftware .gem .mypy_cache .oh-my-zsh/plugins .memestra
  .claude .claude-abd .cmake .calendars .platformio .thunderbird thunderbird go
  Slack Insomnia google-chrome chromium gtk-3.0 gtk-4.0 dconf pulse systemd
  fontconfig ibus fcitx fcitx5 nautilus evolution wireplumber xdg-desktop-portal
  procps swayosd rustdesk khal vdirsyncer mpv imv qalculate SEGGER wiremix
  hyprland-preview-share-picker waybar mako omarchy uwsm menus autostart
  environment.d tool_state elephant aether fallow cliamp composer configstore
  btop eza ngrok xournalpp
)

_fzf_ag_ignores=""
_fzf_fd_excludes=""
for _n in $_fzf_ignore_names; do
  _fzf_ag_ignores="$_fzf_ag_ignores --ignore \"$_n\""
  _fzf_fd_excludes="$_fzf_fd_excludes --exclude \"$_n\""
done
export FZF_AG_IGNORES="$_fzf_ag_ignores"
export FZF_FD_EXCLUDES="$_fzf_fd_excludes"
unset _fzf_ignore_names _fzf_ag_ignores _fzf_fd_excludes _n

export FZF_DEFAULT_COMMAND='ag -g "" --hidden --ignore-case --skip-vcs-ignores '"$FZF_AG_IGNORES"' '"$FZF_SEARCH_PATHS"
export FZF_CONTROL_T_COMMAND='fd --type f --hidden --ignore-case --no-ignore '"$FZF_FD_EXCLUDES"' . '"$FZF_SEARCH_PATHS"
export FZF_ALT_C_COMMAND='fd --type d --hidden --ignore-case --no-ignore '"$FZF_FD_EXCLUDES"' . '"$FZF_SEARCH_PATHS"

# zsh envs
export ZSH=$HOME/.oh-my-zsh

# cargo envs
case ":${PATH}:" in
   *:"$HOME/.cargo/bin":*)
      ;;
   *)
      export PATH="$HOME/.cargo/bin:$PATH"
      ;;
esac

# pip envs
case ":${PATH}:" in
   *:"$HOME/.local/bin":*)
      ;;
   *)
      export PATH="$HOME/.local/bin:$PATH"
      ;;
esac

# bun envs
case ":${PATH}:" in
   *:"$HOME/.bun":*)
      ;;
   *)
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
      ;;
esac

# mise envs
case ":${PATH}:" in
   *:"/usr/bin/mise":*)
      ;;
   *)
     eval "$(mise activate zsh)"
      ;;
esac

# go envs
case ":${PATH}:" in
   *:"$HOME/go/bin":*)
      ;;
   *)
      export PATH="$HOME/go/bin:$PATH"
      ;;
esac

# claude code accounts
claude-app() {
  env -u CLAUDE_CONFIG_DIR claude "$@"
}

claude-abd() {
  CLAUDE_CONFIG_DIR="$HOME/.claude-abd" command claude "$@"
}

# sensitive envs
[ -s "/home/dh/.config/secret-env" ] && source "/home/dh/.config/secret-env"
