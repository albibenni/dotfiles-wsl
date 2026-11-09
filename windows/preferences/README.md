# Restore Windows preferences

Run from **Windows PowerShell as Administrator**, using your usual Windows account.
Copy this folder to Windows first, for example `C:\Users\YOUR_NAME\Downloads\preferences`.

```powershell
cd "$env:USERPROFILE\Downloads\preferences"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\restore.ps1 -WhatIf
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\restore.ps1
```

Brave must already be installed and registered for that account. The installer:

- Sets the machine default-association policy for HTTP, HTTPS, HTM and HTML to
  the handlers registered by Brave. Sign out and back in to apply it.
- Sets display off, idle sleep and idle hibernation timeouts to **Never**, on
  battery and AC power, for the currently active power plan.
- Creates `Dotfiles-RestoreWindowsPreferences` in Task Scheduler to reapply
  power timeouts 30 seconds after your account signs in after each restart.
- Copies its script and browser XML to `%ProgramData%\dotfiles-wsl\preferences`,
  so startup does not depend on WSL or this repository being available.

Windows controls default-browser selection. Its association policy is intended
for managed/domain-joined devices and may not apply on every Windows edition or
standalone device. If Brave is not selected after signing in, open **Settings >
Apps > Default apps > Brave > Set default**. The script does not modify protected
UserChoice hashes. The browser policy is machine-wide; other accounts need Brave
installed with matching handlers. Install under your normal account, not another
administrator's credentials.

Domain/MDM policy can override these settings again. If the resets come from your
organization, its administrator must change the source policy for a lasting fix.
This script does not alter screen locking, screen savers, lid actions, or power
button actions. Never sleeping on battery increases battery consumption.

Reapply the power settings manually:

```powershell
& "$env:ProgramData\dotfiles-wsl\preferences\restore.ps1" -Mode Apply
```

Remove the sign-in task and restore the original browser policy:

```powershell
& "$env:ProgramData\dotfiles-wsl\preferences\restore.ps1" -Mode Uninstall
```

Uninstall preserves a browser policy changed elsewhere and keeps backup files.
It does not restore previous power timeouts or the browser selected in your
profile; choose those in Windows Settings. Reinstalling preserves the original
browser policy backup.

References: [Microsoft powercfg options](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options),
[default browser association policy](https://learn.microsoft.com/en-us/deployedge/edge-default-browser).
