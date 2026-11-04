#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export PATH="$HOME/.local/bin:${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH"
config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
[[ $(readlink -f -- "$config") == "$repo/config/nvim" ]] || {
    echo 'Run scripts/setup.sh first; refusing to sync a different Neovim config.' >&2; exit 1;
}
nvim --headless '+Lazy! restore' +qa
export DOTFILES_WSL_PARSER_INSTALL="$repo/scripts/install-nvim-parsers.lua"
nvim --headless '+lua dofile(vim.env.DOTFILES_WSL_PARSER_INSTALL)'
export DOTFILES_WSL_EDITOR_CHECK="$repo/scripts/check-editor.lua"
nvim --headless '+lua dofile(vim.env.DOTFILES_WSL_EDITOR_CHECK)'
