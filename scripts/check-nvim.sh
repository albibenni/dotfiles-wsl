#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export PATH="$HOME/.local/bin:${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH"
# Exercise the same Bash layer users launch Neovim from. Do not source .bashrc,
# whose corporate startup may prompt for credentials or restart services.
exec bash --noprofile --norc -ic '
    set -e
    source "$1/config/bash/init.sh"
    export DOTFILES_WSL_EDITOR_CHECK="$1/scripts/check-editor.lua"
    nvim --headless "+lua dofile(vim.env.DOTFILES_WSL_EDITOR_CHECK)"
    export DOTFILES_WSL_LSP_CHECK="$1/scripts/check-lsp.lua"
    nvim --headless "+lua dofile(vim.env.DOTFILES_WSL_LSP_CHECK)"
' check-nvim "$repo"
