#!/usr/bin/env bash
set -euo pipefail
[[ $# == 0 || ( $# == 1 && $1 == --dry-run ) ]] || { echo 'Usage: install-tmux-plugins.sh [--dry-run]' >&2; exit 2; }
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
plugins="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins"
while IFS=$'\t' read -r name url revision; do
    [[ -z $name || $name == \#* ]] && continue
    if [[ ! $name =~ ^[a-zA-Z0-9_-]+$ || ! $revision =~ ^[0-9a-f]{40}$ ]]; then
        echo 'Invalid tmux plugin lock entry' >&2; exit 1
    fi
    directory="$plugins/$name"
    if [[ ${1:-} == --dry-run ]]; then
        printf 'Install %s at %s (%s)\n' "$url" "$directory" "$revision"
        continue
    fi
    mkdir -p "$plugins"
    if [[ -e $directory ]]; then
        [[ -d $directory/.git ]] || { printf 'Refusing to replace non-plugin directory: %s\n' "$directory" >&2; exit 1; }
        [[ $(git -C "$directory" remote get-url origin) == "$url" ]] || { printf 'Unexpected plugin remote: %s\n' "$directory" >&2; exit 1; }
        [[ -z $(git -C "$directory" status --porcelain) ]] || { printf 'Plugin has local changes: %s\n' "$directory" >&2; exit 1; }
    else
        git clone --quiet --no-checkout "$url" "$directory"
    fi
    if ! git -C "$directory" cat-file -e "$revision^{commit}" 2>/dev/null; then
        git -C "$directory" fetch --quiet origin "$revision"
    fi
    if [[ $name == tmux ]]; then
        # Catppuccin stays pinned to the original v2.1.3 release.
        git -C "$directory" -c advice.detachedHead=false checkout --quiet --detach "$revision"
    else
        # A dedicated tracking branch lets TPM's `git pull` update these plugins.
        upstream=$(git -C "$directory" symbolic-ref --short refs/remotes/origin/HEAD)
        git -C "$directory" checkout --quiet -B dotfiles-wsl "$revision"
        git -C "$directory" branch --quiet --set-upstream-to="$upstream" dotfiles-wsl
    fi
    printf 'Installed %s at %s\n' "$name" "$revision"
done < "$repo/config/tmux/plugins.lock"
if [[ ${1:-} != --dry-run ]]; then
    printf 'Plugins installed. Reload with: tmux source-file ~/.config/tmux/tmux.conf\n'
fi
