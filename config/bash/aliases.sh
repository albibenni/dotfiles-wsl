alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias vim=nvim
alias pn=pnpm
alias g='git'
alias ga='git add -A'
alias gc='git commit'
alias gp='git push'
alias glool='git --no-pager log --oneline --decorate --graph'
alias gloof='git --no-pager log -n 6 --decorate --graph'
alias gdup='git diff @{upstream}'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias k=kubectl
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias gst='git status -sb'
alias gloo='git --no-pager log -n 30 --oneline --decorate --graph'
alias python=python3
alias d=docker
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then alias bat=batcat; fi
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then alias fd=fdfind; fi
if command -v eza >/dev/null 2>&1; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lta='lt -a'
    alias ll='eza -lah --group-directories-first --icons=auto'
    alias lt='eza --tree --level=2 --long --icons=auto --git'
fi
git_current_branch() { git branch --show-current 2>/dev/null; }
ggpull() {
    local branch
    branch=$(git_current_branch)
    [[ -n $branch ]] || { printf 'No current Git branch.\n' >&2; return 1; }
    git pull origin "$branch" "$@"
}
ggpush() {
    local branch
    branch=$(git_current_branch)
    [[ -n $branch ]] || { printf 'No current Git branch.\n' >&2; return 1; }
    git push origin "$branch" "$@"
}
# Restore the original smart `cd`, keeping standard options and `cd -` working.
zd() {
    if (( $# == 0 )); then builtin cd || return;
    elif (( $# > 1 )) || [[ -z $1 || $1 == -* || -d $1 ]]; then builtin cd "$@" || return;
    else z "$@"; fi
}
if command -v zoxide >/dev/null 2>&1; then alias cd=zd; fi
n() { if (( $# )); then nvim "$@"; else nvim .; fi; }
cdf() { builtin cd -- "$DOTFILES_WSL" || return; }
cdd() { cdf; }
vid() { nvim "$DOTFILES_WSL"; }
vimvim() { nvim "$DOTFILES_WSL/config/nvim"; }
vimux() { nvim "$DOTFILES_WSL/config/tmux/tmux.conf"; }
storage() {
    [[ -n ${STORAGE:-} ]] || { printf 'Set STORAGE in your local Bash overrides first.\n' >&2; return 1; }
    builtin cd -- "$STORAGE" || return
}
_reload_bashrc() {
    # Reload this layer only; do not rerun corporate proxy/authentication startup.
    # shellcheck source=/dev/null
    source "$DOTFILES_WSL/config/bash/init.sh"
}
gprocess() {
    [[ $# == 1 && -n $1 ]] || { printf 'Usage: gprocess PATTERN\n' >&2; return 2; }
    pgrep -af -- "$1"
}
# Run the editor as the current user while sudoedit handles privileged file I/O.
svim() { sudoedit "$@"; }
if command -v new-project-tui >/dev/null 2>&1; then alias new=new-project-tui; fi
ff() {
    local preview=cat
    if type -P bat >/dev/null 2>&1; then preview='bat --style=numbers --color=always';
    elif type -P batcat >/dev/null 2>&1; then preview='batcat --style=numbers --color=always'; fi
    fzf --preview "$preview {}"
}
open() {
    if [[ $# != 1 ]]; then printf 'Usage: open PATH_OR_URL\n' >&2; return 2; fi
    case $1 in
        http://*|https://*)
            if command -v wslview >/dev/null 2>&1; then wslview "$1";
            else printf 'Install wslu or use your Windows browser for URLs.\n' >&2; return 1; fi ;;
        *)
            if command -v explorer.exe >/dev/null 2>&1; then explorer.exe "$(wslpath -w "$(realpath -- "$1")")";
            else xdg-open "$1"; fi ;;
    esac
}
