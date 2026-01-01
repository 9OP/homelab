# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return ;;
esac

# ============================================================================
# Locale (interactive shells only)
# ============================================================================
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# ============================================================================
# History
# ============================================================================
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Up/Down arrow history search based on prefix
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# ============================================================================
# Shell options
# ============================================================================
shopt -s checkwinsize

# ============================================================================
# Prompt (Debian default)
# ============================================================================
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
  xterm-color|*-256color) color_prompt=yes ;;
esac

force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# ============================================================================
# Color support and default aliases (Debian default)
# ============================================================================
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# ============================================================================
# Your aliases (deduped)
# ============================================================================
# File operations
alias ll='ls -alh'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Docker shortcuts
alias dps='docker ps'
alias dlog='docker logs -f'
alias dex='docker exec -it'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate --all'

# System monitoring
command -v htop >/dev/null 2>&1 && alias top='htop'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# System shortcuts
alias ports='sudo ss -tulpn'
alias update='sudo apt-get update && sudo apt-get upgrade'

# Public IP (requires curl)
command -v curl >/dev/null 2>&1 && alias myip='curl -s ifconfig.me'

# Local IP (OS-specific)
if command -v ipconfig >/dev/null 2>&1; then
  # macOS
  alias localip='ipconfig getifaddr en0'
elif command -v hostname >/dev/null 2>&1; then
  # Linux
  alias localip="hostname -I | awk '{print \$1}'"
fi

# ============================================================================
# Command overrides (conditional)
# ============================================================================
# bat vs cat
if command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never'
elif command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

# fd vs find (Debian uses fdfind)
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'

# ripgrep (optional). Note: replacing grep can surprise scripts; kept interactive only.
command -v rg >/dev/null 2>&1 && alias grep='rg'

# ============================================================================
# Custom Functions
# ============================================================================
mkcd() { mkdir -p "$1" && cd "$1"; }
take() { mkdir -p "$1" && cd "$1"; }

extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

findproc() {
  ps aux | grep -i -- "$1" | grep -v grep
}

backup() {
  cp -- "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

qcommit() {
  git add . && git commit -m "$*" && git push
}

usage() {
  du -h -d1 2>/dev/null | sort -hr
}

# ============================================================================
# bash aliases file (Debian default)
# ============================================================================
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# ============================================================================
# bash-completion (Debian default)
# ============================================================================
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ============================================================================
# fzf (optional)
# ============================================================================
if command -v fzf >/dev/null 2>&1; then
  [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
  [ -f /usr/share/doc/fzf/examples/completion.bash ] && . /usr/share/doc/fzf/examples/completion.bash

  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
fi
