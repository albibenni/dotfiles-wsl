# Ghostty resizing under GlazeWM / WSLg

Installed and tested on 2026-11-05 with WSLg 1.0.79, Weston
`a7e35fdab455dce5774b43b8aff682f748307e31`, and GlazeWM 3.10.1.

Source: https://github.com/Mihir-Null/wslg-resize-fix
Pinned source commit: `538c8c0b8446cd8d6b02c1b3f95b3083583d8eec`.
Checkout: `C:\Users\GBS14063\Projects\wslg-resize-fix`.

The patch implements Linux client resizing and a Windows helper relays external
window geometry changes. Modules were built against the exact running Weston
commit. All module exports and imported library symbols passed the upstream ABI
checks. The helper was cross-compiled from Cargo.lock with mise Rust 1.99.1 and
an isolated MinGW compiler; both Windows unit-test binaries passed.
A local installer fix checks for a missing scheduled task before reading State
in Stop-Helper, allowing first installation under PowerShell StrictMode.

## Installed state and feature preservation

Installed with `install -KeepShadow`, without `-NoFrames`. Title bars, window
controls, X11 shadows and decorations stay enabled. The helper skips popups,
owned windows and minimized/maximized windows. No global GTK backend is forced.

Modules/helper: `%LOCALAPPDATA%\wslg-resize-fix`.
The `wslg-resize-sync` per-user scheduled task starts the helper at sign-in.
`%USERPROFILE%\.wslgconfig` contains only the module-path override; `.wslconfig`
networking settings are unchanged. The shims select the exact matching Weston
build and fall back to stock after an unmatched WSLg update.

Activated this boot using upstream `apply` only after verifying that no Linux
GUI windows were open. It restarted Weston, without shutting down Ubuntu or its
shells/services. Stock copies remain in the system distro's /tmp for live revert.
On future WSL starts, the persistent module-map setting loads the shims.

Bash startup, Ghostty config, and live GlazeWM config hashes matched the saved
baseline after testing. Existing staged font-size and GlazeWM opacity edits were
left uncommitted. No terminal, Neovim, tmux, clipboard or audio configuration was
replaced; interactive behavior beyond resizing was not exhaustively tested.

## Test results

Real client dimensions were checked, not just the Windows wrapper rectangle:

- Wayland: 852x1384 tile -> 802x1334 client, with its normal CSD margins.
- After an 80px tile-width increase: 932x1384 -> 882x1334 client.
- X11: 852x1384 tile -> 788x1320 client, with the preserved 32px shadow margins.
- X11 followed the subsequent resize too. Owned test windows were closed.

## Status, updates and rollback

Run in Windows PowerShell:

```powershell
$fix = "$env:USERPROFILE\Projects\wslg-resize-fix\wslg-fix.ps1"
& $fix status -Distro Ubuntu-26.04
```

After a WSLg update, unmatched versions safely use stock modules. Rebuild the
modules before expecting resizing to work again; helper rebuilding needs a
Windows Rust toolchain or the Linux cross-compilation route used for this trial.
Do not run upstream `build-helper` blindly without that toolchain installed.

To remove the persistent configuration and helper startup:

```powershell
& $fix uninstall -Distro Ubuntu-26.04
```

Then, after saving all WSL work, run `wsl --shutdown` to return to stock modules.
This closes all WSL sessions. For a same-boot rollback of the development apply,
`& $fix revert -Distro Ubuntu-26.04` restores the stock module backups and restarts
Weston, closing Linux GUI windows. Do not run either restart with unsaved work.

Configuration baseline/backups are in
`%LOCALAPPDATA%\dotfiles-wsl\wslg-resize-trial`.
Emergency fallback: remove the `WESTON_MODULE_MAP` line from `.wslgconfig`, then
restart WSL after saving work. No WSLg disk image was modified.
