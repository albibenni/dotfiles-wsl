#!/usr/bin/env bash
set -euo pipefail
[[ ${1:-} != --help ]] || { echo 'Usage: install-packages.sh [--dry-run]'; exit 0; }
[[ $# == 0 || ( $# == 1 && $1 == --dry-run ) ]] || { echo 'Usage: install-packages.sh [--dry-run]' >&2; exit 2; }
# shellcheck source=/dev/null
source /etc/os-release
[[ $ID == ubuntu ]] || { echo 'This installer targets Ubuntu.' >&2; exit 1; }
packages=(bash-completion ca-certificates curl git git-delta unzip build-essential
    python3 python3-venv python3-pip neovim tmux ncurses-term
    fzf ripgrep fd-find bat eza zoxide starship shellcheck shfmt black
    wl-clipboard xclip xdg-utils)
if [[ ${1:-} == --dry-run ]]; then
    printf 'sudo apt-get update\nsudo apt-get install -y'
    printf ' %q' "${packages[@]}"
    printf '\n'
    exit 0
fi
sudo apt-get update
# Verify all names before starting an installation. Ubuntu 26.04 is tested.
for package in "${packages[@]}"; do
    if ! apt-cache show "$package" >/dev/null 2>&1; then
        printf 'Package unavailable on this Ubuntu release: %s\n' "$package" >&2
        exit 1
    fi
done
sudo apt-get install -y "${packages[@]}"
nvim --headless -u NONE '+lua if vim.fn.has("nvim-0.11.3") == 0 then vim.cmd("cquit 1") end' +qa || {
    echo 'Neovim >= 0.11.3 is required. Install a newer Neovim before setup.' >&2; exit 1;
}
