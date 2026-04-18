# ~/.bash_aliases
# Common aliases for Debian + Bash + GNOME Terminal + Starship

# --------------------------------------------------
# Safety / quality-of-life
# --------------------------------------------------
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias mkdir='mkdir -pv'
alias ln='ln -iv'

# --------------------------------------------------
# Colorized core utilities
# --------------------------------------------------
alias ls='ls --color=auto'
alias l='ls -CF --color=auto'
alias la='ls -A --color=auto'
alias ll='ls -alFh --color=auto'
alias lt='ls -alFh --color=auto --sort=time'
alias lsize='ls -alFhS --color=auto'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias dmesg='dmesg --color=always'

# --------------------------------------------------
# Navigation
# --------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias home='cd ~'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'
alias au='cd ~/au'

# --------------------------------------------------
# File listing helpers
# --------------------------------------------------
alias lh='ls -d .* --color=auto'
alias tree='tree -C'
alias treed='tree -C -d'
alias cls='clear'
alias path='printf "%s\n" "${PATH//:/\n}"'

# --------------------------------------------------
# Search helpers
# --------------------------------------------------
alias rg='rg --colors=match:fg:yellow'
alias fhere='find . -iname'
alias ff='find . -type f | grep'
alias fd='find . -type d | grep'

# --------------------------------------------------
# Disk / size / system
# --------------------------------------------------
alias df='df -h'
alias du='du -h'
alias duh='du -sh ./* ./.??* 2>/dev/null'
alias free='free -h'
alias psa='ps auxf'
alias psg='ps aux | grep -i'
alias top='top -c'

# --------------------------------------------------
# Git
# --------------------------------------------------
alias g='git'
alias gs='git status'
alias ga='git add .'
alias gc='git commit'
alias gcm='git commit -a -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gst='git stash'

# --------------------------------------------------
# Python / uv / pip / venv
# --------------------------------------------------
alias py='python3'
alias uvr='uv run'
alias uvs='uv sync'

# --------------------------------------------------
# Networking
# --------------------------------------------------
alias ports='ss -tulpn'
alias myip='curl -4 ifconfig.me; echo'
alias pingg='ping google.com'

# --------------------------------------------------
# Better defaults for common viewers
# --------------------------------------------------
alias less='less -R'
alias weather='curl wttr.in'

# --------------------------------------------------
# Confirmation helpers
# --------------------------------------------------
alias please='sudo $(history -p !!)'

# --------------------------------------------------
# Handy custom functions
# --------------------------------------------------

# Make a directory and cd into it
mkcd() {
    mkdir -p -- "$1" && cd -- "$1"
}

# Extract most common archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *) echo "Cannot extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Go up N directories: up 3
up() {
    local d=""
    local limit="${1:-1}"
    for ((i=1; i<=limit; i++)); do
        d+="../"
    done
    cd "$d" || return
}

# Show the current PATH one entry per line
showpath() {
    printf "%s\n" "${PATH//:/\n}"
}

alias cat="batcat"
alias repl='uvx --with ipython ipython -i -c "import os; clear = lambda: os.system(\"clear\")"'

cdf() {
    local dir
    # Uses the cleaner logic from codef: 
    # Ignores hidden paths and searches for the optional argument $1
    dir=$(find . -not -path '*/.*' -type d -name "*$1*" 2>/dev/null | \
          fzf --height 40% --reverse --border)

    # If a directory was selected, change into it
    if [ -n "$dir" ]; then
        cd "$dir" || return
    fi
}

codef() {
  local dir
  dir=$(find . -not -path '*/.*' -type d -name "*$1*" 2>/dev/null | fzf --height 40% --reverse --border)

  if [ -n "$dir" ]; then
    code "$dir" --disable-gpu
  fi
}

repo() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        cd "$(git rev-parse --show-toplevel)" || return
    else
        local project_root="~/code"
        local selected

        selected=$(find "${project_root:-.}" -maxdepth 2 -name ".git" -type d | \
                   rev | cut -d/ -f2- | rev | \
                   fzf --height 40% --reverse --header "Jump to Repository")

        if [ -n "$selected" ]; then
            cd "$selected" || return
        else
            echo "Not in a git repo and no selection made."
        fi
    fi
}

hf() {
    local query cmd

    query="${1:-}"

    cmd="$(
        history \
        | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//' \
        | grep -F -- "$query" \
        | fzf
    )" || return

    [ -n "$cmd" ] && eval "$cmd"
}
