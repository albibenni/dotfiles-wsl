# dotfiles-wsl

A standalone Bash development environment for Ubuntu on WSL2, adapted from
[dotfile_arch_btw](https://github.com/albibenni/dotfile_arch_btw).
No submodules, desktop compositor, Zsh, hardware tweaks, or Arch installers.
The original repository is not needed after this repository is created.

## Install

Tested against Ubuntu 26.04 with Neovim 0.11.6 and tmux 3.6. Python 3.11+ is
needed for the setup scripts; Neovim 0.11.3+ is needed for this editor config.
Use the Linux filesystem, for example `~/dotfiles-wsl`.

```bash
cd ~/dotfiles-wsl
./scripts/install.sh --dry-run
./scripts/install.sh
```

The full installer runs these steps, in order:

1. `scripts/install-packages.sh`: installs Ubuntu packages with `sudo apt-get`.
2. `scripts/install-tools.sh`: uses your existing mise to add missing Node,
   TypeScript/Python/Bash language servers, and Prettier. Existing tool entries,
   including `node = "lts"`, win. No mise installer is downloaded.
3. `scripts/setup.sh`: backs up conflicting configs, creates explicit symlinks,
   and appends one loader block to your existing `.bashrc`.
4. `scripts/install-tmux-plugins.sh`: installs the four original tmux plugins at
   revisions recorded in `config/tmux/plugins.lock`.
5. `scripts/install-plugins.sh`: downloads/restores the locked Neovim plugins with lazy.nvim.

Open a new Bash shell after installation. Your current shell is not reloaded by
the installer. Corporate Kerberos/proxy startup code stays in the original
`.bashrc`; `.profile`, `.bash_profile`, SSH, DNS, Docker, credentials, and Git
identity are not replaced. Do not run the full installer with `sudo`: only the
APT commands require it. Downloads inherit the current proxy environment.

Each step can also run separately. Package and tool installers accept
`--dry-run`; setup supports `--dry-run` and optional `--git`.

```bash
./scripts/setup.sh --git --dry-run
./scripts/setup.sh --git
```

`--git` adds an include for delta, a few aliases, LF checkout handling and
`zdiff3` conflicts. It leaves your existing identity/credentials intact. Install
packages first, since this optional config requires `delta`. It does not change
pull/rebase policy or install destructive Git aliases.

The default setup does not modify your mise config until `install-tools.sh`
runs. The tracked `config/mise/tools.toml` is a list of defaults to merge, not a
replacement for your global config. Existing requested versions are not changed;
missing versions may be downloaded. Tools other than Node currently track
`latest`; pin the versions in the template before a fresh installation if needed.

## Resuming a timed-out installation

The tool installer allows 120 seconds for version lookups and 60 seconds for
HTTP requests, accommodating corporate proxies. These settings apply only to
the script; explicit environment overrides are preserved. It keeps mise's
normal proxy and TLS certificate handling.

APT packages already installed do not need reinstalling. Resume with:

```bash
./scripts/install-tools.sh
./scripts/setup.sh
./scripts/install-plugins.sh
```

If a lookup still times out, check that your proxy is running and your Kerberos
ticket is valid, then retry. To allow longer requests explicitly:

```bash
MISE_FETCH_REMOTE_VERSIONS_TIMEOUT=5m MISE_HTTP_TIMEOUT=2m ./scripts/install-tools.sh
```

## Included

- Bash: original Readline/history settings, Git and Kubernetes shortcuts,
  dotfile-editing helpers, Neovim aliases, `ff` previews and Ctrl+S layer reload.
  Existing `.bashrc` remains intact; this layer loads from its existing loader.
- fzf: Ctrl+R history, Ctrl+T files, Alt+C directories. Standard Tab completion.
- zoxide: original smart `cd` via `zd` plus `z`; existing directories, multiple
  arguments, options and `cd -` retain builtin Bash behavior.
- eza with Nerd Font file icons and bat, handling Ubuntu's `batcat` and `fdfind` executable names.
- Starship: the original cyan two-line prompt with Nerd Font Git/language icons,
  detailed Git state, language versions, Docker/Kubernetes context when relevant,
  command duration, and clock. Uses CaskaydiaCove Nerd Font selected in the Windows
  terminal; no separate WSL font installation is needed. Ubuntu Starship 1.22
  lacks the original native mise module, so that segment is omitted and its
  language modules display the active runtime versions instead.
- tmux: the original TPM, Catppuccin v2.1.3, tmux-cpu, and kube-tmux plugins,
  rounded teal/gray tabs, folder/clock/CPU modules, mouse and vi copy mode.
  Kubernetes context is shown when `kubectl` or `oc` is on the tmux server's PATH.
  WSL clipboard helpers, project picker, terminal settings and keybindings remain.
- Neovim: Tokyo Night, Telescope, Gitsigns, Fugitive, native LSP/completion and
  Conform formatting. TypeScript/JavaScript, Python, and Bash language servers.
  No automatic formatting or whitespace edits on save. No AI credentials or
  integrations, personal Todoist hooks, or desktop theme dependencies.
- Windows clipboard helpers with Wayland/X11 fallbacks.

APT packages include the shell tools plus Python, build utilities, SSL
certificates, Neovim, tmux, ShellCheck, shfmt, Black, and clipboard utilities.
`ripgrep` is installed explicitly instead of relying on a copy bundled in Codex.
Older Ubuntu releases may lack `starship`, `eza`, `git-delta`, or a recent Neovim;
the package script stops on unavailable package names rather than adding third
party repositories.

## Shortcuts

| Where | Shortcut | Action |
|---|---|---|
| Bash | Ctrl+F | Select project and attach/switch tmux session |
| Bash | Ctrl+R | fzf command history |
| Bash | `z name` / `cd name` | Jump to a previously visited directory |
| Bash | Ctrl+S | Reload only the dotfiles Bash layer |
| Bash | `cdd` / `cdf` | Open this dotfiles directory |
| Bash | `vid` / `vimvim` / `vimux` | Edit dotfiles / Neovim / tmux config |
| tmux | Ctrl+B then h/j/k/l | Select pane |
| tmux | Ctrl+B then H/J/K/L | Resize pane |
| tmux | Ctrl+B then f | Project picker in a new window |
| tmux | Ctrl+B then [ | Copy mode; v selects, y copies to clipboard |
| tmux | Ctrl+B then r | Reload config |
| Neovim | Space p f / Space p s | Find files / search text |
| Neovim | Space p b | Pick buffer |
| Neovim | Space e | File browser |
| Neovim | gd / gr / K | Definition / references / documentation |
| Neovim | Space r n / Space c a | Rename / code action |
| Neovim | Ctrl+X Ctrl+O | Native LSP completion menu |
| Neovim | Space f | Format buffer or selection |
| Neovim | `:Git` | Fugitive Git interface |

## Bash settings

The existing `.bashrc` is preserved, including corporate Kerberos/proxy startup.
Its managed loader sources `config/bash/init.sh`. Shell options, aliases,
environment defaults, Readline settings and optional completion hooks live in
`config/bash/`, with no recursive sourcing of `personal/` or copied `.bash_profile`.

Ported from the original:

- History append, 32K history entries, completion settings, prefix-history arrows,
  Unicode input/output, colored file types, symlink completion, and `set +h`.
- `vim`, `pn`, `python`, `g`, `ga`, `gc`, `gp`, `gst`, `gloo`, `glool`, `gloof`,
  `gdup`, `gcm`, `gcam`, `gcad`, `ggpull`, `ggpush`, `k`, `kgp`, `kgpw`, `d`.
- `lsa`, `lt`, `lta`, `..`, `...`, `....`, `n`, `ff`, `cdd`, `vid`, `vimvim`,
  `vimux`, `git_current_branch`, `gprocess`, and `svim` (using `sudoedit`).
- Ctrl+F project picker, Ctrl+S reload, and disabled Ctrl+S terminal flow control.
  Ctrl+S reloads just this layer, so proxy/authentication startup is not repeated.
- `DOTFILES` points to this repo; editor defaults, Neovim man pager, Go/PNPM paths,
  and a replacement for the missing `addToPathFront` helper. Existing editor,
  pager, Go, PNPM, and FZF environment choices are respected.
- Smart `cd`: existing directory paths and standard options use builtin `cd`;
  other names use zoxide. Override it locally with `unalias cd` if preferred.
- kubectl completion for `k`, plus `try` and task-planner initialization, when
  those commands are installed. These optional applications are not installed
  just to provide their aliases. `pn` likewise requires pnpm to be installed.

Machine-specific mount/project paths, forced locales/compilers, desktop terminal
settings, Omarchy/Hyprland commands, generated application startup blocks, and
secret files are excluded. `storage` works after defining your own `STORAGE` in
`~/.config/dotfiles-wsl.local.sh`. Personal overrides load last. To reload now:

```bash
source ~/dotfiles-wsl/config/bash/init.sh
```

This reload does not edit or re-source `.bashrc`. Open a new shell to discard any
settings you manually removed from the configuration during the current session.

## Tmux plugins

The full installer includes the plugins. To install or restore them separately:

```bash
./scripts/install-tmux-plugins.sh --dry-run
./scripts/install-tmux-plugins.sh
tmux source-file ~/.config/tmux/tmux.conf
```

Downloads live in `~/.local/share/tmux/plugins` (or `$XDG_DATA_HOME/tmux/plugins`),
outside the dotfiles repository. The installer uses `config/tmux/plugins.lock` to
restore known revisions and refuses to overwrite local plugin edits. TPM still
provides **Ctrl+B then I** to install declared plugins, **Ctrl+B then U** to
update unpinned plugins, and **Ctrl+B then Alt+u** to clean removed plugins.
Catppuccin remains pinned to v2.1.3; skip it in TPM's update menu. The other three
use dedicated tracking branches so TPM updates work. Updates can move away from
the locked revisions; rerunning the script restores those revisions.

Catppuccin is loaded before composing the status line, then TPM loads the plugins
and tmux-cpu expands the CPU placeholders. Reloading rebuilds the status line
without duplicating modules. No tmux session restart is needed.

The CPU figure measures the WSL VM. tmux-cpu works with the existing `ps` fallback;
`sudo apt-get install sysstat` optionally provides more accurate sampling.
Kubernetes CLI/context setup is separate: the plugin is installed but hidden
until `kubectl` or `oc` is available to tmux. It reads local context/namespace.

## Appearance

Select **CaskaydiaCove Nerd Font** in the Windows terminal running WSL. The prompt,
tmux separators, and eza file icons use it. A new Bash shell loads the updated
aliases; Starship reads its configuration on each prompt.

```bash
# Reload the appearance in an existing tmux server:
tmux source-file ~/.config/tmux/tmux.conf
```

## Local preferences and projects

Put optional Bash changes in `~/.config/dotfiles-wsl.local.sh` (outside this
repository). Only that explicit file is sourced; no directory is auto-sourced.

```bash
cp config/projects.example ~/.config/dotfiles-wsl-projects
```

Edit it to list your actual project directories, one per line. Leading `~` is
expanded, and spaces are supported. Variables, shell code, and paths containing
newlines are not supported in that file. Without it the picker searches
`~/projects` and `~/dotfiles-wsl`, to depth two. It includes an 8-character path
hash in session names so equal project basenames do not share a session.
It creates a background session and attaches outside tmux; inside tmux it switches.

Clipboard copy uses `clip.exe` with UTF-16 conversion for Unicode. Paste uses
PowerShell with UTF-8 output. These require WSL Windows interoperability and the
Windows tools on PATH, as in the source environment. Otherwise an available
Wayland/X11 clipboard is used. No external clipboard provider is required for
normal terminal text selection. Clipboard commands operate on your actual system
clipboard; the validation suite does not modify it.

`open PATH` opens an existing path in Windows Explorer. `open URL` uses `wslview`
when separately installed; URLs can also be opened directly in your browser.

Neovim dependencies are explicit: APT supplies `rg`, `shfmt`, and `black`, and
mise supplies the language servers and `prettier`. Add other languages only when
needed. `:checkhealth` diagnoses providers. `:Lazy sync` updates plugins;
`config/nvim/lazy-lock.json` is tracked to record resolved plugin revisions.
First plugin synchronization creates the lockfile if it is absent.

## Restore

Every setup that changes something prints its backup manifest under
`~/.local/state/dotfiles-wsl/backups/<timestamp>/manifest.json`.

```bash
./scripts/restore.sh ~/.local/state/dotfiles-wsl/backups/TIMESTAMP/manifest.json --dry-run
./scripts/restore.sh ~/.local/state/dotfiles-wsl/backups/TIMESTAMP/manifest.json
```

Restore removes the matching managed symlinks and puts backed-up configs back.
It removes only the loader block from `.bashrc`, preserving edits made after
setup. It also removes a Git include added by that setup. It refuses to replace
managed paths that have since been changed to something else. Restore newer
manifests before older ones. A full pre-setup `.bashrc` copy is retained in the
backup directory for manual recovery. Installed packages and mise tools remain.
Open a fresh shell, and start a fresh tmux server when safe to clear in-memory
settings. Moving the repo requires rerunning setup; restore the previous links
first if needed.

## Verify and publish

```bash
./scripts/check.sh
# Optional after setup and installing dependencies:
./scripts/install-plugins.sh
```

The offline checks cover TOML parsing, LF line endings, non-destructive dry-run,
setup idempotence, config backups/restoration, retained Bash edits, changed-path
protection, Neovim base startup, and project picker quoting/attach/switch behavior.
ShellCheck runs when installed. The checks also cover mise version preservation,
malformed TOML rejection, and Unicode conversion for the Windows clipboard. Neovim plugin synchronization uses the network;
it is deliberately separate from offline checks.

```bash
git add .
git commit -m "Add Ubuntu WSL dotfiles"
git remote add origin git@github.com:YOUR_USER/dotfiles-wsl.git
git push -u origin main
```

No remote is configured automatically. Keep tokens, SSH keys, and private local
configuration out of this repository. All tracked text files use LF endings.
