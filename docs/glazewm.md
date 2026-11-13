# GlazeWM on Windows, based on the Hyprland config

GlazeWM runs on **Windows**, alongside WSLg. The port reads the personal bindings
and appearance in `dotfile_arch_btw/hypr/.config/hypr/`; it does not install
Hyprland or Omarchy in Ubuntu. It targets GlazeWM 3.10.1's current config format.

From WSL:

```bash
cd ~/dotfiles-wsl
./scripts/install-glazewm.sh --dry-run --start
./scripts/install-glazewm.sh --start
# Optional: also start at Windows sign-in
./scripts/install-glazewm.sh --startup --start
```

The installer uses Windows winget's exact `glzr-io.glazewm` package. Its official
WiX variable `Custom_InstallZebar=0` excludes the optional bar. Windows may request
administrator consent for package installation. `--skip-packages` requires an
existing installation; `--distro NAME` selects another WSL distribution.
The Linux package installer does not automatically start a Windows window manager.

The source is `config/glazewm/config.yaml`. The installer substitutes the WSL
distribution and copies it, plus the cheat sheet, into
`%USERPROFILE%\.glzr\glazewm`. This avoids needing WSL to be running when Windows
starts the manager. Rerun after editing the source. Changed destination files are
backed up under `%LOCALAPPDATA%\dotfiles-wsl\glazewm-backups\<timestamp>`;
unchanged files are skipped. Existing directory junctions and file symlinks are
rejected. `.bashrc`, Linux configs and Windows shortcut policies are untouched.

PowerShell directly (the repository can also be checked out on Windows):

```powershell
.\windows\glazewm\install.ps1 -Distro Ubuntu-26.04 -WhatIf -Start
.\windows\glazewm\install.ps1 -Distro Ubuntu-26.04 -Start
```

## Shortcuts

**Super means either Windows key.** GlazeWM intercepts the listed combinations
while running. Other Windows shortcuts remain enabled; no `NoWinKeys` policy or
keyboard-wide remapping is applied by the installer.
**Win+L focuses right**, alongside Alt+L and Win+Right. This requires Windows
`DisableLockWorkstation=1`, which must be configured separately. That policy disables
manual workstation locking; the installer does not change it. If locking is
restored, remove `win+l` and use the alternatives. The configured custom lock
shortcut also cannot lock while workstation locking is disabled.

| Shortcut | Action |
|---|---|
| Win+H / J / K / L | Focus left / down / up / right |
| Win+arrows | Directional focus |
| Win+Shift+H/J/K/L or arrows | Move window in direction |
| Win+Ctrl+H/J/K/L | Resize by 40 px |
| Win+1…9 / 0 (top row or number pad) | Workspace 1…9 / 10 |
| Win+Shift+1…9 / 0 | Move to workspace without following |
| Win+Tab / Win+Shift+Tab | Next / previous active workspace |
| Win+Ctrl+Tab | Recent workspace |
| Win+W | Close focused window |
| Win+T / Win+O | Toggle centered floating |
| Win+F | Toggle fullscreen |
| Win+Alt+F / Win+Ctrl+F | Toggle maximized/full-width equivalent |
| Win+Alt+J | Change split direction |
| Win+Alt+Space | Cycle tiled/floating/fullscreen focus |
| Win+Shift+T | WezTerm in the selected WSL distro |
| Win+Shift+F | Explorer |
| Win+Shift+B | Default browser (Google start page) |
| Win+Shift+C / Y | Calendar / YouTube |
| Win+Ctrl+C / G | Claude / Gemini web |
| Win+F1 | Open full shortcut list in Notepad |
| Win+Ctrl+Shift+R | Reload config |
| Win+Ctrl+Shift+P | Pause/resume management and other bindings |
| Win+Ctrl+Shift+Escape | Exit GlazeWM and restore normal Windows handling |

Number-pad workspace keys require Num Lock on. Both Win+number and
Win+Shift+number accept the top row and number pad.

Native Win+V opens Windows clipboard history, Win+Shift+S screenshots,
and Alt+Tab switches applications. These replace the equivalent Linux menus.
The original Win+K menu conflicts with Vim-style upward focus: this port uses
Win+K for focus and Win+F1 for the keybinding list.

### Conflicting Windows and PowerToys shortcuts

PowerToys Mouse Highlighter defaults to **Win+Shift+H**, which is also the
GlazeWM shortcut for moving a window left. In PowerToys Settings → Mouse Utilities
→ Mouse Highlighter, disable the utility or change its activation shortcut. The
Windows registry setting below does not disable PowerToys shortcuts.

For Explorer's conflicting Win+letter and Win+number shortcuts, an optional
per-user configuration is available from Windows PowerShell:

```powershell
.\windows\glazewm\disable-conflicting-hotkeys.ps1 -WhatIf
.\windows\glazewm\disable-conflicting-hotkeys.ps1
# To restore the value saved before the first change:
.\windows\glazewm\disable-conflicting-hotkeys.ps1 -Restore
```

Sign out and back in after applying or restoring it. This uses Explorer's
`DisabledHotkeys` setting, which is not a complete list of Windows shortcuts:
Windows-reserved combinations, arrow keys, Tab, and other applications can
still conflict. It disables Explorer shortcuts by key, including combinations
with modifiers, and applies even when GlazeWM is stopped. It preserves existing
entries and saves the original value under `%LOCALAPPDATA%\dotfiles-wsl`.
Restoring replaces the entire value with that original, so review any later
changes before restoring. This setting does not change workstation locking.
Microsoft's broader [Windows Key hotkeys policy](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-admx-windowsexplorer#nowindowshotkeys)
also disables unrelated shortcuts such as Win+E and Win+R. To apply that policy
and disable workstation locking for Win+L, run the following in Windows
PowerShell, as administrator if your registry permissions require it:

```powershell
.\windows\glazewm\windows-hotkeys-policy.ps1
# To restore the original policy values:
.\windows\glazewm\windows-hotkeys-policy.ps1 -Restore
```

Sign out and back in after either command. These policies apply even when
GlazeWM is stopped. Disabling workstation locking also prevents the configured
lock shortcut from locking the workstation. Windows can still reserve some
combinations; verify the desired bindings after signing back in. The restore
command replaces policy values with their saved originals, including any changes
made since the backup. The separate `DisabledHotkeys` setting above has its own
restore command.

## Appearance and differences

- Ten workspaces. Hyprland `gaps_in=4` becomes an 8-pixel gap between adjacent
  windows; outer gaps stay 4 pixels, scaled with monitor DPI.
- TokyoNight border colors match the terminal. Native Windows 11 small rounded
  corners approximate rounding 5; Windows controls border thickness.
- Focused opacity is 95%; unfocused opacity is 85%, approximating the original
  95% opacity plus 10% dimming. Windows transparency differs from compositor
  dimming. Disable `transparency.enabled` in both effects sections if unwanted.
- Picture-in-picture floats at 600x338, always on top; standard dialogs float.
  Title bars remain usable. WSLg applications appear as Windows RDP proxy windows,
  so app-specific Linux class/opacity rules cannot be copied directly.
- GlazeWM supports horizontal/vertical split trees, not Hyprland's scrolling
  layout, pseudo tiling, scratchpad, animations or per-monitor mode setting.
  Display resolution/scaling/rotation stays in Windows Display settings.
- Workspaces 1-9 bind to monitor 0 (the lower Xiaomi); workspace 10 binds to
  monitor 1 (the upper LG UltraGear). The observed monitor order is DISPLAY1 at
  index 0 (3440x1440) and DISPLAY2 at index 1 (2560x1440). Monitor indexes are not Windows
  display numbers. Workspaces 1 and 10 stay alive. GlazeWM falls back when a
  bound display is absent; edit `bind_to_monitor` if the monitor order changes.
  Display resolution and scaling stay in Windows Display settings.
- Linux-only app launches, Omarchy menus, theme scripts, notification services,
  audio/brightness daemons and display toggles are omitted. Native Windows
  controls continue to provide those functions. Zebar is an optional future port
  of the Waybar appearance; this setup retains the Windows taskbar.

## Inspect, stop, and restore

From Windows PowerShell (full CLI path also works before PATH refresh):

```powershell
$cli = "$env:ProgramFiles\glzr.io\GlazeWM\cli\glazewm.exe"
& $cli query app-metadata
& $cli query windows
& $cli query monitors
& $cli command wm-toggle-pause
& $cli command wm-exit
```

To remove optional startup, delete only `Dotfiles-GlazeWM.lnk` from `shell:startup`.
If using GlazeWM's own tray startup option, turn that off in its tray separately;
do not enable both mechanisms. To restore a previous config, exit GlazeWM and
copy the desired backed-up `config.yaml` into `%USERPROFILE%\.glzr\glazewm`.
Uninstalling the package is separate: `winget uninstall --id glzr-io.glazewm -e`.

Official references: [GlazeWM config and reserved keys](https://github.com/glzr-io/glazewm#config-documentation),
[config template](https://github.com/glzr-io/glazewm/blob/v3.10.1/resources/assets/sample-config.yaml),
[installer options](https://github.com/glzr-io/glazewm/blob/v3.10.1/resources/wix/bundle.wxs).
