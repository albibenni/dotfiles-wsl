#!/usr/bin/env bash
set -euo pipefail
[[ $# == 0 || ( $# == 1 && $1 == --dry-run ) ]] || { echo 'Usage: install-wezterm.sh [--dry-run]' >&2; exit 2; }
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
command -v powershell.exe >/dev/null || { echo 'Windows PowerShell interop is required.' >&2; exit 1; }
windows_home=$(powershell.exe -NoProfile -NonInteractive -Command '[Environment]::GetFolderPath("UserProfile")' | tr -d '\r\n')
[[ -n $windows_home ]] || { echo 'Windows user profile could not be detected.' >&2; exit 1; }
target="$(wslpath -u "$windows_home")/.wezterm.lua"
source_config="$repo/windows/wezterm/wezterm.lua"
if [[ -f $target ]] && cmp -s "$source_config" "$target"; then echo 'WezTerm config is already current.'; exit 0; fi
printf 'Copy %s -> %s (back up existing config)\n' "$source_config" "$target"
[[ ${1:-} != --dry-run ]] || exit 0
if [[ -e $target || -L $target ]]; then
    backup="${target}.backup.$(date +%Y%m%dT%H%M%S).$$"
    cp -L -- "$target" "$backup"
    printf 'Backup: %s\n' "$backup"
fi
# Replace the file itself so an existing symlink does not redirect the write.
temporary=$(mktemp "${target}.tmp.XXXXXX")
trap 'rm -f -- "$temporary"' EXIT
cp -- "$source_config" "$temporary"
mv -f -- "$temporary" "$target"
echo 'Installed. WezTerm reloads its config automatically; new tabs use WSL.'
