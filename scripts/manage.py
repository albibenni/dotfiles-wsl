#!/usr/bin/env python3
"""Link an explicit set of configs; preserve the existing Bash startup file."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import subprocess

REPO = Path(__file__).resolve().parents[1]
START = "# >>> dotfiles-wsl >>>"
END = "# <<< dotfiles-wsl <<<"
BLOCK = START + '\n[ ! -r "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles-wsl/config/bash/init.sh" ] || . "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles-wsl/config/bash/init.sh"\n' + END + '\n'


def exists(path):
    return path.exists() or path.is_symlink()


def remove_block(text):
    if START not in text:
        return text
    if text.count(START) != 1 or text.count(END) != 1:
        raise SystemExit("Malformed dotfiles-wsl block in .bashrc; fix it before continuing.")
    before, remainder = text.split(START, 1)
    _, after = remainder.split(END, 1)
    if after.startswith("\n"):
        after = after[1:]
    return before + after


def setup(args):
    home = Path.home()
    config = Path(os.environ.get("XDG_CONFIG_HOME", str(home / ".config")))
    state = Path(os.environ.get("XDG_STATE_HOME", str(home / ".local/state"))) / "dotfiles-wsl/backups"
    targets = {
        config / "dotfiles-wsl": REPO,
        config / "tmux": REPO / "config/tmux",
        config / "nvim": REPO / "config/nvim",
        config / "starship.toml": REPO / "config/starship.toml",
    }
    pending = [(t, s) for t, s in targets.items() if not (t.is_symlink() and t.resolve() == s)]
    rc = home / ".bashrc"
    text = rc.read_text() if rc.exists() else ""
    if rc.is_symlink():
        raise SystemExit(".bashrc is a symlink; merge the documented loader manually first.")
    if START in text:
        # Validate instead of silently accepting a malformed managed block.
        remove_block(text)
        if BLOCK not in text:
            raise SystemExit("Managed Bash block differs from this version; restore it before setup.")
    add_block = START not in text
    include = str(REPO / "config/git/config")
    includes = subprocess.run(["git", "config", "--global", "--get-all", "include.path"], capture_output=True, text=True)
    add_git = args.git and include not in includes.stdout.splitlines()
    if not (pending or add_block or add_git):
        print("Already configured; nothing changed.")
        return
    for target, source in pending:
        print(f"Link {target} -> {source}" + (" (back up existing)" if exists(target) else ""))
    if add_block:
        print(f"Append managed loader to {rc}; retain all existing content")
    if add_git:
        print(f"Add optional Git include: {include}")
    if args.dry_run:
        return
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    backup = state / stamp
    backup.mkdir(parents=True)
    manifest = {"home": str(home), "links": [], "bashrc": None, "git_include": None}
    def save():
        (backup / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    save()
    for index, (target, source) in enumerate(pending):
        saved = backup / f"config-{index}" if exists(target) else None
        entry = {"target": str(target), "source": str(source), "backup": str(saved) if saved else None}
        # Journal before moving, so partial setup is recoverable.
        manifest["links"].append(entry)
        save()
        target.parent.mkdir(parents=True, exist_ok=True)
        if saved:
            shutil.move(str(target), str(saved))
        target.symlink_to(source, target_is_directory=source.is_dir())
    if add_block:
        if rc.exists():
            shutil.copy2(rc, backup / "bashrc.original")
        manifest["bashrc"] = str(rc)
        save()
        with rc.open("a") as handle:
            handle.write(("\n" if text and not text.endswith("\n") else "") + BLOCK)
    if add_git:
        manifest["git_include"] = include
        save()
        subprocess.run(["git", "config", "--global", "--add", "include.path", include], check=True)
    print(f"Backup manifest: {backup / 'manifest.json'}")
    print("Open a new Bash shell to activate. Git include is optional; setup --git enables it.")


def restore(args):
    path = Path(args.manifest).resolve()
    data = json.loads(path.read_text())
    if Path(data["home"]) != Path.home():
        raise SystemExit("Backup belongs to a different HOME.")
    if data.get("restored"):
        print("This backup was already restored.")
        return
    # Preflight all paths before removing any links.
    for entry in data["links"]:
        target = Path(entry["target"])
        if exists(target) and not (target.is_symlink() and str(target.readlink()) == entry["source"]):
            raise SystemExit(f"Refusing to replace a path changed since setup: {target}")
    rc = Path(data["bashrc"]) if data["bashrc"] else None
    text = rc.read_text() if rc and rc.exists() else ""
    if rc and rc.is_symlink():
        raise SystemExit(".bashrc became a symlink; restore manually.")
    clean_text = remove_block(text)
    for entry in reversed(data["links"]):
        target = Path(entry["target"])
        print(f"Restore {target}")
        if not args.dry_run:
            if target.is_symlink():
                target.unlink()
            if entry["backup"] and exists(Path(entry["backup"])):
                shutil.move(entry["backup"], str(target))
    if args.dry_run:
        return
    if rc:
        rc.write_text(clean_text)
    if data["git_include"]:
        result = subprocess.run(["git", "config", "--global", "--fixed-value", "--unset-all", "include.path", data["git_include"]])
        if result.returncode not in (0, 5):
            result.check_returncode()
    data["restored"] = True
    path.write_text(json.dumps(data, indent=2) + "\n")
    print("Restored original configs; other Bash changes were retained. Open a new shell.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    install = commands.add_parser("setup")
    install.add_argument("--dry-run", action="store_true")
    install.add_argument("--git", action="store_true", help="include the optional Git settings")
    rollback = commands.add_parser("restore")
    rollback.add_argument("manifest", help="path printed by setup")
    rollback.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    (setup if args.command == "setup" else restore)(args)


if __name__ == "__main__":
    main()
