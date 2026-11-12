# Native Windows WezTerm + Ubuntu WSL

The config is `windows/wezterm/wezterm.lua`. It selects `WSL:Ubuntu-26.04`
when available, falls back to the first discovered WSL distro, and starts in
Linux home. PowerShell is available in the launcher. No Linux WezTerm package
is needed. Install CaskaydiaCove Nerd Font in Windows for prompt/editor icons;
Cascadia Code is the text fallback.

From a normal WSL terminal:

```bash
cd ~/dotfiles-wsl
./scripts/install-wezterm.sh --dry-run
./scripts/install-wezterm.sh
```

This detects the Windows profile using PowerShell, backs up `.wezterm.lua` if
present, and copies the config. Rerun after editing the tracked source. An
existing `.wezterm.lua` takes precedence over a config under `.config/wezterm`.
If `WEZTERM_CONFIG_FILE` is set on Windows, that override must be removed or
updated to use this file.

If Windows interoperability is unavailable in your agent session, run this in
Windows PowerShell instead (it preserves the previous file):

```powershell
$target = Join-Path $env:USERPROFILE '.wezterm.lua'
if (Test-Path $target) {
    Copy-Item $target "$target.backup.$(Get-Date -Format yyyyMMddTHHmmssfff)"
}
Copy-Item '\\wsl.localhost\Ubuntu-26.04\home\albibenni\dotfiles-wsl\windows\wezterm\wezterm.lua' $target
```

WezTerm reloads saved configuration automatically. Open a new window/tab to use
the new default WSL domain. Change the preferred domain near the top of the Lua
file if `wsl.exe --list --quiet` lists a different distro name.

## Features to try

| Shortcut | Feature |
|---|---|
| Ctrl+Shift+Space | Quick Select: type a displayed label to copy a URL, hash or path |
| Ctrl+Shift+X | Keyboard copy mode for selecting terminal output |
| Ctrl+Shift+F | Search the scrollback, including output that has scrolled away |
| Ctrl+Shift+P | Searchable command palette |
| Ctrl+A, then v / s | Split side by side / above and below |
| Ctrl+A, then h/j/k/l | Move between WezTerm panes |
| Ctrl+A, then z | Zoom the current pane |
| Ctrl+A, then p | Select a pane with a visible label |
| Ctrl+A, then t | Launcher: choose a WSL distro or Windows PowerShell |
| Ctrl+A, then Ctrl+A | Send Ctrl+A to Bash (start of line) |

Leader shortcuts are sequential: release Ctrl+A before pressing the next key.
Tmux keeps its existing Ctrl+B prefix. Use tmux for persistent Linux sessions;
WezTerm panes provide a convenient way to put WSL beside PowerShell. Search and
Quick Select see the terminal's rendered history; use tmux copy mode to search
history retained inside tmux.

Appearance: Tokyo Night colors, 13 pt font, padded edges, quiet bell, 20,000
scrollback lines and a tab bar that appears when there are multiple tabs.

Official references: [WSL domains](https://wezterm.org/config/lua/WslDomain.html),
[Quick Select](https://wezterm.org/quickselect.html),
[default keyboard shortcuts](https://wezterm.org/config/default-keys.html).
