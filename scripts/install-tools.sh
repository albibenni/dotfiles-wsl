#!/usr/bin/env bash
set -euo pipefail
[[ $# == 0 || ( $# == 1 && $1 == --dry-run ) ]] || { echo 'Usage: install-tools.sh [--dry-run]' >&2; exit 2; }
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export PATH="$HOME/.local/bin:$PATH"
# Proxy-backed version lookups can exceed mise's default 20-second budget.
# Apply only to this installer and its children; preserve explicit overrides.
export MISE_FETCH_REMOTE_VERSIONS_TIMEOUT="${MISE_FETCH_REMOTE_VERSIONS_TIMEOUT:-120s}"
export MISE_HTTP_TIMEOUT="${MISE_HTTP_TIMEOUT:-60s}"
command -v mise >/dev/null 2>&1 || { echo 'mise must already be installed.' >&2; exit 1; }
global_config="${MISE_GLOBAL_CONFIG_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml}"
# Parse TOML, never source it. Existing requested versions always win.
specs_text=$(python3 - "$repo/config/mise/tools.toml" "$global_config" <<'PYTHON'
import pathlib, sys, tomllib
requested = tomllib.loads(pathlib.Path(sys.argv[1]).read_text())["tools"]
path = pathlib.Path(sys.argv[2])
existing = tomllib.loads(path.read_text()).get("tools", {}) if path.exists() else {}
for key, version in requested.items():
    if key not in existing:
        print(f"{key}@{version}")
PYTHON
)
specs=()
if [[ -n $specs_text ]]; then mapfile -t specs <<< "$specs_text"; fi
if [[ ${1:-} == --dry-run ]]; then
    printf 'export MISE_FETCH_REMOTE_VERSIONS_TIMEOUT=%q MISE_HTTP_TIMEOUT=%q\n' "$MISE_FETCH_REMOTE_VERSIONS_TIMEOUT" "$MISE_HTTP_TIMEOUT"
    for spec in "${specs[@]}"; do printf 'mise -C %q use --global %q\n' "$HOME" "$spec"; done
    printf 'mise -C %q install node npm:typescript npm:typescript-language-server npm:bash-language-server npm:pyright npm:prettier\nmise reshim\n' "$HOME"
    exit 0
fi
# Node comes first so npm backends can use it in noninteractive shells.
for spec in "${specs[@]}"; do mise -C "$HOME" use --global "$spec"; done
mise -C "$HOME" install node npm:typescript npm:typescript-language-server npm:bash-language-server npm:pyright npm:prettier
mise reshim
