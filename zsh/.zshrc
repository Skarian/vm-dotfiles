# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  z
  git
  tmux
  web-search
  fzf
)

# User configuration
source "$HOME/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh"

if [ -s "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Environment variables
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.local/bin:$HOME/node/bin:$HOME/.cargo/bin:$PYENV_ROOT/bin:$PATH"
export EMSDK_QUIET=1
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"

# Tool initialization
if [[ -o interactive ]] && [[ -z "${ZSH_EXECUTION_STRING:-}" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
if [[ -o interactive ]] && [[ -z "${ZSH_EXECUTION_STRING:-}" ]] && command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

# Aliases
alias j='just'
alias ls='eza -l --icons=always --no-permissions --no-user -h -a'
alias nvim="NVIM_APPNAME=astronvim_v4 nvim"

# Rename tmux windows for common command runners when appropriate.
function preexec() {
  if [[ -n ${TMUX} ]]; then
    local -a cmd=(${(z)1})
    local current_terminal
    current_terminal=$(tmux display-message -p '#{pane_current_command}')

    if [[ "${current_terminal}" != "nvim" ]]; then
      if { [[ "${cmd[1]}" == "just" ]] || [[ "${cmd[1]}" == "j" ]]; } && (( $#cmd > 1 )) && [[ "${cmd[2]}" != -* ]]; then
        tmux rename-window "${cmd[2]}"
      fi
    fi
  fi
}

# Startup
if [[ -o interactive ]] && [[ -z "${ZSH_EXECUTION_STRING:-}" ]] && command -v macchina >/dev/null 2>&1; then
  macchina
fi
