#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fonts_source="${DOTFILES_WSL_WINDOWS_HOME:-/mnt/c/Users/GBS14063}/AppData/Local/Microsoft/Windows/Fonts"
dry_run=false
while (( $# )); do
    case $1 in
        --dry-run) dry_run=true; shift ;;
        --fonts)
            (( $# >= 2 )) || { echo '--fonts requires a directory' >&2; exit 2; }
            fonts_source=$2; shift 2 ;;
        *) echo 'Usage: install-ghostty.sh [--dry-run] [--fonts DIRECTORY]' >&2; exit 2 ;;
    esac
done
shopt -s nullglob
fonts=("$fonts_source"/CaskaydiaCoveNerdFont-*.ttf)
(( ${#fonts[@]} )) || { printf 'CaskaydiaCove Nerd Font files not found in %s. Use --fonts DIRECTORY.\n' "$fonts_source" >&2; exit 1; }
fonts_target="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/CaskaydiaCoveNerdFont"
if ! command -v ghostty >/dev/null 2>&1 || ! command -v fc-cache >/dev/null 2>&1; then
    if $dry_run; then echo 'sudo apt-get update'; echo 'sudo apt-get install -y ghostty fontconfig';
    else sudo apt-get update; sudo apt-get install -y ghostty fontconfig; fi
fi
if $dry_run; then
    printf 'Copy %s font files to %s\n' "${#fonts[@]}" "$fonts_target"
    "$repo/scripts/setup.sh" --dry-run
    printf 'Validate Ghostty config and font discovery\n'
    exit 0
fi
mkdir -p "$fonts_target"
for font in "${fonts[@]}"; do install -m 644 "$font" "$fonts_target/"; done
fc-cache -f "$fonts_target"
"$repo/scripts/setup.sh"
ghostty +validate-config
family=$(fc-match -f '%{family}' 'CaskaydiaCove Nerd Font')
[[ $family == *CaskaydiaCove* ]] || { printf 'Font did not resolve correctly: %s\n' "$family" >&2; exit 1; }
printf 'Ghostty configured with %s. Start it using: ghostty\n' "$family"
