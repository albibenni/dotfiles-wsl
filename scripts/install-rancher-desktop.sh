#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
args=()
distro=${WSL_DISTRO_NAME:-Ubuntu}
while (( $# )); do
    case $1 in
        --dry-run) args+=(-WhatIf); shift ;;
        --startup) args+=(-EnableStartup); shift ;;
        --skip-packages) args+=(-SkipPackages); shift ;;
        --distro)
            (( $# >= 2 )) && [[ -n $2 && $2 != --* ]] || { echo '--distro requires a WSL distribution name' >&2; exit 2; }
            distro=$2; shift 2 ;;
        *) echo 'Usage: install-rancher-desktop.sh [--dry-run] [--startup] [--skip-packages] [--distro NAME]' >&2; exit 2 ;;
    esac
done
[[ $distro =~ ^[A-Za-z0-9_.-]+$ ]] || { echo "Invalid WSL distribution name: $distro" >&2; exit 2; }
powershell=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
[[ -x $powershell ]] || { echo 'Windows PowerShell/WSL interop is required.' >&2; exit 1; }
exec "$powershell" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File \
    "$(wslpath -w "$repo/windows/rancher-desktop/install.ps1")" -Distro "$distro" "${args[@]}"
