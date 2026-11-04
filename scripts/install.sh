#!/usr/bin/env bash
set -euo pipefail
[[ $# == 0 || ( $# == 1 && $1 == --dry-run ) ]] || { echo 'Usage: install.sh [--dry-run]' >&2; exit 2; }
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
"$repo/scripts/install-packages.sh" "$@"
"$repo/scripts/install-tools.sh" "$@"
"$repo/scripts/setup.sh" "$@"
if [[ ${1:-} != --dry-run ]]; then
    "$repo/scripts/install-plugins.sh"
    printf '\nDone. Open a new Bash shell to load the configuration.\n'
fi
