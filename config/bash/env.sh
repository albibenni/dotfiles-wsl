# Sourced after XDG_CONFIG_HOME and DOTFILES_WSL have been established.
export DOTFILES="$DOTFILES_WSL"
export VIM=nvim
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export GIT_EDITOR="${GIT_EDITOR:-$EDITOR}"
export SUDO_EDITOR="${SUDO_EDITOR:-$EDITOR}"
export MANPAGER="${MANPAGER:-nvim +Man!}"
export BAT_THEME="${BAT_THEME:-ansi}"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border}"
export FZF_COMPLETION_TRIGGER="${FZF_COMPLETION_TRIGGER:-**}"
export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="${GOBIN:-$HOME/.local/bin}"
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"

# Compatibility for scripts that used Omarchy's missing path helper.
# Quote arguments; avoid duplicate entries on reload.
addToPathFront() {
    local directory=$1
    case ":$PATH:" in
        *":$directory:"*) ;;
        *) export PATH="$directory:$PATH" ;;
    esac
}
for _dotfiles_directory in "$GOBIN" "$GOPATH/bin" "$PNPM_HOME" "$HOME/.cargo/bin" "$HOME/.local/share/bin"; do
    [[ ! -d $_dotfiles_directory ]] || addToPathFront "$_dotfiles_directory"
done
unset _dotfiles_directory
