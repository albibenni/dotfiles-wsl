#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export PATH="$HOME/.local/bin:${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH"
exec bash --noprofile --norc -ic '
    set -e
    source "$1/config/bash/init.sh"
    export DOTFILES_WSL_JAVA_CHECK="$1/scripts/check-java.lua"
    nvim --headless "+lua dofile(vim.env.DOTFILES_WSL_JAVA_CHECK)"
' check-java "$repo"
