# Ghostty on WSL

Ghostty runs as a Linux GUI application through WSLg. Ubuntu 26.04 provides the
`ghostty` package. Your normal Bash, Starship, tmux and Neovim configuration works
inside its window; no Hyprland, Zsh, or desktop environment is installed.

```bash
cd ~/dotfiles-wsl
./scripts/install-ghostty.sh --dry-run
./scripts/install-ghostty.sh
```

The script installs `ghostty`/`fontconfig` through APT only if missing, copies your
already-installed Windows CaskaydiaCove fonts into Linux's user-font directory,
links the config with the existing backup-aware setup, and validates font lookup
and Ghostty syntax. It does not rewrite `.bashrc`. Override the Windows font
source with `--fonts DIRECTORY` on a different machine.

The config uses CaskaydiaCove Nerd Font, 14 pt SemiBold, TokyoNight Night colors,
the original padding/cursor/keybindings, and Bash shell integration. It omits
Omarchy theme paths, the Hyprland epoll workaround and macOS-only font thickening.
Optional overrides go in `~/.config/ghostty.local`. If an existing Ghostty config
is present, setup backs it up before linking.

## Use it as your everyday terminal

1. In Windows Start, search for **Ghostty (Ubuntu-26.04)**. WSLg creates that entry
   when the Ubuntu package is installed.
2. Launch it, then right-click its taskbar icon and choose **Pin to taskbar**.
3. Use that pinned icon instead of the Windows Terminal/Ubuntu console launcher.
   Move it to the first taskbar position to open it with **Win+1**.

From an existing WSL shell you can run `ghostty`. From Windows Run/PowerShell:

```powershell
wslg.exe -d Ubuntu-26.04 -- /usr/bin/ghostty
```

This opens Ghostty's own window. Do not put `exec ghostty` in `.bashrc`: Ghostty
also starts Bash, which would recursively launch terminals. The existing Bash
layer sets `TERMINAL=ghostty` when installed, preserving a pre-existing choice.
That variable is used by some Linux helpers; it does not change Windows settings.

## What Windows "default terminal" means

The WSLg/Linux build is not a Windows console-host provider and cannot replace
Windows Terminal in the Windows **Default terminal application** dropdown.
Shortcuts and pinned apps are the appropriate way to make it your usual WSL
terminal. Other Windows console apps and "Open in Terminal" actions still use
Windows' selected console host. Windows Terminal's default profile selects a
shell in Windows Terminal; it does not turn Windows Terminal into Ghostty.

Windows' default-terminal setting is documented by
[Microsoft](https://learn.microsoft.com/en-us/windows/terminal/customize-settings/startup#default-terminal-application).
WSLg Start/taskbar integration is documented in
[Linux GUI apps on WSL](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps).

## Optional Linux default terminal alternative

If you also want applications using Ubuntu's `x-terminal-emulator` alternative
to use Ghostty, run these in WSL (requires sudo):

```bash
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 30
sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty
```

This changes Ubuntu's terminal alternative only, not Windows' console host.
