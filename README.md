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
2. `scripts/install-tools.sh`: uses your existing mise for missing Node, language
   servers, formatters, lazygit and the Neovim 0.11-compatible Treesitter CLI.
   pnpm, Temurin Java 25 and Maven are included. Existing tool entries,
   including `node = "lts"`, win. A separate TypeScript 6
   installation provides tsserver without replacing a global TypeScript 7.
   No mise installer is downloaded.
3. `scripts/install-jdtls.sh`: installs the pinned, checksummed Java language server.
4. `scripts/setup.sh`: backs up conflicting configs, creates explicit symlinks,
   and appends one loader block to your existing `.bashrc`.
5. `scripts/install-tmux-plugins.sh`: installs the four original tmux plugins at
   revisions recorded in `config/tmux/plugins.lock`.
6. `scripts/install-agent-skills.sh`: installs the 19 vendored skills with backups.
7. `scripts/install-plugins.sh`: restores locked Neovim plugins, builds native
   fzf, installs syntax parsers, and verifies the UI, mappings and plugin setup.

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
- Neovim: original editing options/keymaps, Tokyo Night, Lualine, NvimTree,
  Telescope/native fzf, Harpoon, nvim-cmp/LuaSnip, Gitsigns/Fugitive/LazyGit,
  Treesitter/textobjects/autotag, Flash, WhichKey, Trouble, TODO comments,
  Comment/surround/indent guides, Undotree, Zen mode and Markview. LSP and Conform
  handle installed language tools. No automatic formatting/whitespace edits on
  save, AI credentials/integrations, Todoist hooks or desktop theme dependencies.
  See [the Neovim comparison](docs/nvim-audit.md) for adaptations and optional tools.
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
| Neovim | Space e e / Space e f | File tree / locate current file |
| Neovim | gd / gr / K | Definition / references / documentation |
| Neovim | Space r n / Space c a | Rename / code action |
| Neovim | Ctrl+Space / Ctrl+N / Ctrl+P | Completion menu / next / previous |
| Neovim | Space a / Ctrl+E | Harpoon add / menu |
| Neovim | Space nn / Space tt | Undo history / diagnostics |
| Neovim | Space lg / Space gs | LazyGit / Fugitive |
| Neovim | Ctrl+F | Telescope tmux project picker |
| Neovim | Space f | Format buffer or selection |
| Neovim | `:Git` | Fugitive Git interface |

## pnpm, Java and agent skills

The setup now includes pnpm, Temurin Java 25, Maven, the dedicated Neovim JDTLS
integration and 19 skills from your original skills repo. See
[pnpm, Java/JDTLS and agent skills](docs/java-and-skills.md) for paths, shortcuts,
installer/restore commands and the WSL script review.

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

## Rancher Desktop on Windows / WSL

Install Rancher Desktop, enable integration with the current WSL distro, and
prevent Ubuntu's native Docker service from conflicting with its socket:

```bash
./scripts/install-rancher-desktop.sh --dry-run --startup
./scripts/install-rancher-desktop.sh --startup
```

See [installation, repair and rollback](docs/rancher-desktop.md). This installer
is separate from Linux package installation and preserves existing container data.

## Windows tiling with GlazeWM

The optional Windows window manager mirrors the Hyprland workspaces, Vim-style
controls, Ghostty launcher and appearance using GlazeWM. It uses Windows/Super
shortcuts, with Win+L for right focus after separately disabling Windows locking.
Alt+L and Win+Right remain available.

```bash
./scripts/install-glazewm.sh --dry-run --start
./scripts/install-glazewm.sh --start
# Optional Windows sign-in startup:
./scripts/install-glazewm.sh --startup --start
```

This installs on Windows through winget, excludes Zebar, and backs up changed
Windows configs. It is separate from the Linux installer. See
[GlazeWM setup, shortcuts and differences](docs/glazewm.md).

## Ghostty on WSL

Ghostty is optional and has its own installer:

```bash
./scripts/install-ghostty.sh
```

It reuses your Windows Nerd Font in Linux and links `config/ghostty/config`.
Launch **Ghostty (Ubuntu-26.04)** from Windows Start and pin it to the taskbar to
use it as your everyday WSL terminal. The Linux build cannot be selected as the
Windows default console host. See [Ghostty setup and defaults](docs/ghostty-wsl.md).

## Appearance

Select **CaskaydiaCove Nerd Font** in the Windows terminal running WSL. The prompt,
tmux separators, Neovim icons, and eza file icons use it. A new Bash shell loads
the updated aliases; Starship reads its configuration on each prompt.

The original terminal configs use JetBrainsMono Nerd Font (Ghostty also lists
CaskaydiaCove as a fallback). Neovim uses `nvim-web-devicons` and `lspkind`;
there is no separate desktop icon theme involved in terminal glyph rendering.
The larger Windows preset is in `windows-terminal/ubuntu-font.json`: the installed
CaskaydiaCove Nerd Font at 14 pt, semibold. Use the `Nerd Font`/`NF` family, rather
than `Nerd Font Mono`/`NFM`, for the larger glyph variants.

Installing a font in Windows does not select it for Windows Terminal. To apply the
preset to just the `Ubuntu-26.04` profile, preserving the other profiles/defaults:

```bash
python3 scripts/configure-windows-terminal.py \
  --settings '/mnt/c/Users/YOUR_WINDOWS_USER/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json' \
  --dry-run
# Repeat without --dry-run to apply; optionally use --size 13 or --size 15.
```

The script keeps a backup beside settings.json and expects plain JSON. For a
commented JSONC file, use Windows Terminal Settings → Ubuntu-26.04 → Appearance
instead. Open a fresh Ubuntu-26.04 tab afterward. Font size scales both text and
icons; individual icon sizes are not controlled by Neovim's icon provider.
The supported profile fields are documented in
[Windows Terminal font settings](https://learn.microsoft.com/en-us/windows/terminal/customize-settings/profile-appearance#font).

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
newlines are not supported in that file. Without it the picker includes `~/dotfiles` (falling back to this repo if that
path is absent) and searches `/mnt/c/Users/GBS14063` to depth two, including
repositories inside its `Projects` directory. This machine's `~/dotfiles` is a
symlink to `~/dotfiles-wsl`. The dotfiles repo appears once as a project rather
than exposing all its config folders. `AppData`, `.cache`, `.git` and
`node_modules` directories are pruned; child symlinks/junctions are not followed.
Both Bash and Neovim use `bin/tmux-projects`, so their lists stay consistent.
For a different Windows home, set `DOTFILES_WSL_WINDOWS_HOME` in your local Bash
overrides or list your preferred roots in the override file. It includes an 8-character path
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

Neovim dependencies are explicit: APT supplies `rg`, `shfmt`, and `black`;
existing build-essential compiles the fzf extension and syntax parsers. Mise
supplies Node, TypeScript/Python/Bash/Lua language servers, Prettier, StyLua,
lazygit and tree-sitter 0.25. Neovim 0.11 uses Treesitter's frozen master branch
and matching textobjects API, not main's Neovim 0.12 API. TypeScript 6 is installed
side by side for tsserver while existing global TypeScript versions are retained.
Other LSPs/formatters/linters activate only when their executables are available.
Add runtimes/servers for other languages when needed. `:checkhealth` diagnoses providers. `:Lazy sync` updates plugins;
`config/nvim/lazy-lock.json` is tracked to record resolved plugin revisions.
First plugin synchronization creates the lockfile if it is absent. Put optional
user extensions in `~/.config/nvim-local.lua`, outside the tracked config.

For a full editor validation using temporary files (after installing tools):

```bash
./scripts/check-nvim.sh
```

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

## Neovim runtime errors after updating an existing shell

If an older shell reports `module 'vim.diagnostic' not found` or cannot open
`nvim/syntax/syntax.vim`, reload the corrected Bash layer:

```bash
source ~/dotfiles-wsl/config/bash/init.sh
nvim
```

The earlier port exported `VIM=nvim`, but `VIM`/`VIMRUNTIME` name runtime
**directories**, not the editor command. The fixed layer removes only those known
invalid values; custom runtime-directory overrides are preserved. Use `EDITOR`
or `GIT_EDITOR` to select an editor. Opening a new Bash shell also loads the fix.
The regression checks launch Neovim from the actual configured Bash layer.

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
