[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=1

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Add wisely, as too many plugins slow down shell startup.
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git node zsh-autosuggestions zsh-syntax-highlighting pipenv)

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# enable fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ~/.oh-my-zsh/oh-my-zsh.sh
[ -s /etc/zsh/zprofile ] && source "/etc/zsh/zprofile"

# User configuration
source $HOME/.config/dotfiles/zsh/.zsh_aliases

# bindkey
source $HOME/.config/dotfiles/zsh/.zsh_custom_keys

zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

# libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"


# bun completions
[ -s "/home/dh/.bun/_bun" ] && source "/home/dh/.bun/_bun"

# pnpm
export PNPM_HOME="/home/dh/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pnpm env
export PATH="$HOME/.local/bin:$PATH"

# ssh-agent: one agent reused across all shells (env cached in file), keys live 15min
# skip entirely if SSH_AUTH_SOCK already points at a live socket (forwarded agent, or parent shell already sourced it)
if [ ! -S "$SSH_AUTH_SOCK" ]; then
  SSH_ENV="$HOME/.ssh/agent-env"
  if [ -f "$SSH_ENV" ]; then
    source "$SSH_ENV" > /dev/null
  fi
  if ! { [ -n "$SSH_AGENT_PID" ] && kill -0 "$SSH_AGENT_PID" 2>/dev/null && [ -S "$SSH_AUTH_SOCK" ]; }; then
    (umask 077; ssh-agent -s -t 900 > "$SSH_ENV")
    source "$SSH_ENV" > /dev/null
  fi
fi

# ssh-askpass: GUI passphrase prompt only when no tty available (non-interactive shells, sandboxes)
export SSH_ASKPASS="/usr/lib/ssh/ssh-askpass"
[ -t 0 ] || export SSH_ASKPASS_REQUIRE="prefer"
