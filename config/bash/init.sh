# Sourced by interactive Bash; keep the existing Ubuntu .bashrc intact.
[[ $- == *i* ]] || return 0
DOTFILES_WSL=$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../.." && pwd)
export DOTFILES_WSL
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
case ":$PATH:" in
    *":$DOTFILES_WSL/bin:"*) ;;
    *) export PATH="$DOTFILES_WSL/bin:$PATH" ;;
esac
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
# Put mise shims on PATH even if mise was activated earlier by the existing rc.
if command -v mise >/dev/null 2>&1; then
    case ":$PATH:" in
        *":${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:"*) ;;
        *) export PATH="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH" ;;
    esac
    # Activate once; the existing rc in this WSL already activates mise.
    if ! declare -F _mise_hook >/dev/null && ! declare -F _mise_hook_prompt_command >/dev/null && [[ ${DOTFILES_WSL_MISE_ACTIVE:-0} != 1 ]]; then
        eval "$(mise activate bash)"
        DOTFILES_WSL_MISE_ACTIVE=1
    fi
fi
export EDITOR=nvim VISUAL=nvim SUDO_EDITOR=nvim
export BAT_THEME=ansi
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_COMPLETION_TRIGGER='**'
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE=65536
shopt -s histappend checkwinsize
source "$DOTFILES_WSL/config/bash/aliases.sh"
bind -f "$DOTFILES_WSL/config/bash/inputrc"
# Load fzf only once, including when .bashrc is reloaded.
if command -v fzf >/dev/null 2>&1 && [[ ${DOTFILES_WSL_FZF_ACTIVE:-0} != 1 ]]; then
    if fzf --bash >/dev/null 2>&1; then
        eval "$(fzf --bash)"
    else
        for f in /usr/share/bash-completion/completions/fzf /usr/share/doc/fzf/examples/completion.bash /usr/share/fzf/completion.bash; do
            if [[ -r $f ]]; then source "$f"; break; fi
        done
        for f in /usr/share/doc/fzf/examples/key-bindings.bash /usr/share/fzf/key-bindings.bash; do
            if [[ -r $f ]]; then source "$f"; break; fi
        done
    fi
    DOTFILES_WSL_FZF_ACTIVE=1
fi
if command -v zoxide >/dev/null 2>&1; then eval "$(zoxide init bash)"; fi
if command -v starship >/dev/null 2>&1; then eval "$(starship init bash)"; fi
bind -x '"\C-f":"tmux-sessionizer"'
# Personal additions are deliberately outside Git and are the only extra import.
[[ ! -r $HOME/.config/dotfiles-wsl.local.sh ]] || source "$HOME/.config/dotfiles-wsl.local.sh"
