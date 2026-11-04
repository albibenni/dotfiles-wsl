#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
while IFS= read -r -d '' file; do bash -n "$file"; done < <(find "$repo/scripts" "$repo/bin" "$repo/config/bash" -type f \( -name '*.sh' -o -path "$repo/bin/*" \) -print0)
python3 "$repo/tests/check.py"
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck -x "$repo"/scripts/*.sh "$repo"/bin/*
    shellcheck -s bash -x "$repo"/config/bash/*.sh
fi
printf 'Checks passed.\n'
