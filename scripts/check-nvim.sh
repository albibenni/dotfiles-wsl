#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export PATH="$HOME/.local/bin:${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH"
export DOTFILES_WSL_EDITOR_CHECK="$repo/scripts/check-editor.lua"
nvim --headless '+lua dofile(vim.env.DOTFILES_WSL_EDITOR_CHECK)'
export DOTFILES_WSL_LSP_CHECK="$repo/scripts/check-lsp.lua"
nvim --headless '+lua dofile(vim.env.DOTFILES_WSL_LSP_CHECK)'
