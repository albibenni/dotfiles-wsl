alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias ga='git add -A'
alias gc='git commit'
alias gp='git push'
alias gst='git status -sb'
alias gloo='git --no-pager log -n 30 --oneline --decorate --graph'
alias python=python3
alias d=docker
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then alias bat=batcat; fi
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then alias fd=fdfind; fi
if command -v eza >/dev/null 2>&1; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias ll='eza -lah --group-directories-first --icons=auto'
    alias lt='eza --tree --level=2 --icons=auto --git'
fi
# zoxide supplies `z`; normal `cd` keeps standard Bash behavior.
n() { if (( $# )); then nvim "$@"; else nvim .; fi; }
cdf() { builtin cd -- "$DOTFILES_WSL"; }
ff() {
    local preview=cat
    if command -v bat >/dev/null 2>&1; then preview='bat --style=numbers --color=always';
    elif command -v batcat >/dev/null 2>&1; then preview='batcat --style=numbers --color=always'; fi
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
