# pnpm, Java/JDTLS and agent skills

## Tools

`config/mise/tools.toml` adds pnpm, Temurin Java 25 and Maven. Existing global
version requests are preserved by `scripts/install-tools.sh`. Projects can select
a different JDK with their own mise configuration. Node LTS stays unchanged.

```bash
./scripts/install-tools.sh
./scripts/install-jdtls.sh
./scripts/install-plugins.sh
```

JDTLS 1.63.0 is downloaded from Eclipse at the URL and SHA-256 recorded in
`config/java/jdtls.json`. No root privileges or Mason toolchain are needed. The
archive is checked before extraction; installs live under
`~/.local/share/dotfiles-wsl/jdtls/`. Old versions are retained when updating.

The `bin/jdtls` launcher always uses mise's Temurin 25 installation to run the
server, independently of a project's JDK. Eclipse's current server requires
[Java 25](https://github.com/eclipse-jdtls/eclipse.jdt.ls#requirements). This does
not force every project to target Java 25: choose a project's language level in
its Maven/Gradle configuration, and install/configure its JDK as needed.

Neovim uses `nvim-jdtls` for Java only; the generic LSP loop does not start a
second Java server. Maven/Gradle/Eclipse/Git roots are recognized. Each project
gets a workspace under Neovim's Linux state directory and its own configuration
cache; a hash of its full path prevents same-name projects sharing an index.
No index is written into `/mnt/c` projects. The Java Treesitter parser is included.

Restored settings include signature help, class-file decompilation, filtered
completion types and favorite static imports. `Space c o` organizes imports;
`Space j v` extracts a variable; `Space j c` extracts a constant; visual
`Space j m` extracts a method. Standard definition/references/rename/code-action
keys remain. Debugging and JUnit launch extensions are not bundled; the original
configuration also supplied no debug/test bundles.

```bash
# Real server and type-error check using a temporary Eclipse Java project:
./scripts/check-java.sh
pnpm --version
java -version
mvn --version
```

## Skills snapshot

The original skills submodule's working tree had staged deletions. Those were
left untouched. The 19 skills were retrieved at the exact commit recorded in
`agent/source.json` with the skill-installer helper, and vendored under
`agent/skills/` so this repository has no submodule/network dependency for skill
installation. Only actual skill folders and their resources are installed; the
upstream README and installer are not mixed into discovery directories.

```bash
./scripts/install-agent-skills.sh --dry-run
./scripts/install-agent-skills.sh
# Or select one consumer:
./scripts/install-agent-skills.sh --target codex
```

| Consumer | Destination | Installation |
|---|---|---|
| Codex | `$CODEX_HOME/skills` or `~/.codex/skills` | Physical copies |
| Shared agents | `~/.agents/skills` | Individual file symlinks |
| Original generic agent path | `~/.config/agent/skills` | Individual file symlinks |
| Claude Code | `~/.claude/skills` | Individual file symlinks |
| Gemini CLI | `~/.gemini/skills` | Individual file symlinks |
| Antigravity CLI | `~/.gemini/antigravity-cli/skills` | Individual file symlinks |
| Antigravity shared config | `~/.gemini/config/skills` | Individual file symlinks |

These are WSL/Linux user paths. A Windows-native agent launched outside WSL uses
its Windows home and will not automatically read these Linux paths.

The original script's Linux commands work on WSL, but its force-link/root-unlink
behavior can replace existing configuration, and the outer wrapper covered only
two consumers. The port keeps existing roots and unrelated skills, refuses to
traverse destination directory symlinks, copies real Codex files, backs up
conflicting files/symlinks, and skips unchanged files on rerun. It does not read or
modify `.bashrc`, credentials, or settings for installed agent applications.

Every change records a manifest under
`~/.local/state/dotfiles-wsl/agent-skills/<timestamp>/manifest.json`. Restore with:

```bash
./scripts/install-agent-skills.sh --restore /path/to/manifest.json --dry-run
./scripts/install-agent-skills.sh --restore /path/to/manifest.json
```

Restore refuses to overwrite files changed after installation. Existing `.system`
skills and unrelated custom skills are retained. After editing vendored skills,
rerun the installer to refresh Codex's physical copies. New skills are available
to Codex on the next turn; reload/restart other agents according to their UI.

Antigravity's current discovery paths are documented in
[Customization discovery](https://antigravity.google/docs/customization-discovery?tab=cli).
