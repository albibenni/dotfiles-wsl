# Neovim comparison with dotfile_arch_btw

The original repo remains unchanged. The WSL config is standalone under
`config/nvim/`, with plugin revisions recorded in `lazy-lock.json`.
Your `.bashrc`, `.profile`, `.vimrc`, Windows terminal settings, and secrets are
not edited by this Neovim port.

## Restored

- Original relative numbers, cursor line, no wrap, 120-column guide, indentation,
  split direction, English/Italian spell configuration, centered navigation,
  register-preserving paste/delete, clipboard yank, split/save/edit-config keys.
- Tokyo Night fallback, original custom Lualine palette, NvimTree icons/layout,
  Telescope mappings and native fzf extension, Harpoon 2 bookmarks.
- nvim-cmp with buffer/path/LSP sources, LuaSnip/friendly-snippets, lspkind icons.
- Gitsigns signs/hunk keys, Fugitive merge keys, and LazyGit command/keybinding.
- Treesitter highlighting, indentation, supported textobjects/motions/swaps,
  autotag, Flash navigation, Comment and Surround, indent guides.
- WhichKey, Trouble diagnostics, TODO highlighting/search/navigation, Undotree,
  Zen mode, Markview, and the original optional VimBeGood/rain commands.
- Manual Conform formatting and optional nvim-lint linters, with missing
  optional linters skipped. Project `vp`/Biome formatters are preferred when
  available, with Prettier fallback for installed web formatters.
- Telescope tmux picker using the same project roots as the Bash picker. It
  reuses the corrected session script for quoted paths and unique session names.

## Fixed while porting

| Original issue | WSL adaptation |
|---|---|
| Treesitter main plus legacy `configs`/textobjects API | Use the Neovim 0.11-compatible master branches and CLI 0.25 |
| Native Telescope extension configured with `build = "cmake"` | Use its supported `make` target |
| Unspecified TypeScript could resolve to v7 without tsserver | Install TypeScript 6 alongside global tools; pass its tsserver path in the LSP initialize request; prefer compatible project-local installations |
| Lualine inactive color references undefined `semilightgray` | Use the defined foreground color |
| Zen mode calls undefined `ColorMyPencils()` | Toggle the configured window options directly |
| `<leader>ts` assigned to both spellcheck and Todoist | Retain spellcheck; leave Todoist unconfigured |
| Startup unconditionally invokes Copilot even when unavailable | No unconditional AI command or automatic authentication |
| Personal `~/.dotfiles` paths and tmux picker roots | Resolve this repo and read `~/.config/dotfiles-wsl-projects` |
| Multiple independent tmux jobs race to create/switch sessions | Reuse the sequential Bash sessionizer |
| Clipboard expects Wayland/OSC 52 behavior | Use the tested Windows clipboard copy/paste helpers |
| Opening a file can download a broad Mason toolchain | Install explicit baseline tools with mise; enable other servers only when installed |
| Automatic whitespace edits on every save | Preserve file text unless explicitly formatting/editing |
| Neovim shares Vim's undo directory | Use Neovim's own state directory |
| NvimTree tries to hijack an already-disabled netrw | Disable netrw hijacking explicitly |

The original property textobject captures refer to custom queries absent from
the checkout; those unsupported captures are not mapped. Standard assignments,
parameters, functions, classes, loops and conditionals are retained. Repeatable
motion integration is left to Flash/builtin motions, avoiding overlapping `f`/`;`
rewrites from the old configuration.

## Explicit optional scope

AI plugins (Copilot/Avante/CopilotChat), ask-ai selection integration, and Todoist
are not enabled. Their account credentials and backend configuration were not
ported. Omarchy theme synchronization and transparency hooks are not needed in
WSL. Tokyo Night is the original repo's non-Omarchy fallback.

The default installer supplies TypeScript/JavaScript, Python, Bash and Lua
language tooling. Go, Java, Rust, Zig, HTML/CSS, Docker, GraphQL, Svelte, Biome,
Emmet and Tailwind servers can activate when you install their executables; it
does not download every language ecosystem automatically. Python Black is in the
Ubuntu package list; isort/pylint and other specialized formatters/linters remain
optional. No package manager is launched from an LSP keybinding.

## Validation

`./scripts/check-nvim.sh` loads all plugins, checks UI/keybindings, opens/closes
the file tree, loads parsers and native fzf, then initializes real TS/Python/Bash/
Lua servers on temporary files. It verifies deliberate TypeScript and Python
type errors and Prettier output. It does not write the system clipboard, open a
real project, edit shell startup, or enable AI services.

The compatibility choices follow the upstream
[Treesitter 0.11 branch](https://github.com/nvim-treesitter/nvim-treesitter/tree/master)
and [TypeScript language server installation](https://github.com/typescript-language-server/typescript-language-server#installing).
