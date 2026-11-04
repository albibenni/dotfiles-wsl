#!/usr/bin/env python3
"""Install the vendored skill snapshot without replacing skill-root directories."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import tempfile

REPO = Path(__file__).resolve().parents[1]
SOURCE = REPO / 'agent/skills'


def present(path):
    return path.exists() or path.is_symlink()


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def targets():
    home = Path.home()
    config = Path(os.environ.get('XDG_CONFIG_HOME', str(home / '.config')))
    return {
        'codex': (Path(os.environ.get('CODEX_HOME', str(home / '.codex'))) / 'skills', 'copy'),
        'agents': (home / '.agents/skills', 'link'),
        'agent': (config / 'agent/skills', 'link'),
        'claude': (home / '.claude/skills', 'link'),
        'gemini': (home / '.gemini/skills', 'link'),
        'antigravity-cli': (home / '.gemini/antigravity-cli/skills', 'link'),
        'antigravity': (home / '.gemini/config/skills', 'link'),
    }


def inspect_target(root, target):
    current = target.parent
    while True:
        if current.is_symlink():
            raise SystemExit(f'Refusing to traverse a destination directory symlink: {current}')
        if current == root:
            break
        current = current.parent


def install(args):
    skills = sorted(path for path in SOURCE.iterdir() if path.is_dir() and (path / 'SKILL.md').is_file())
    if not skills:
        raise SystemExit('No SKILL.md folders found in the vendored snapshot.')
    plans = []
    counts = {}
    for consumer, (root, mode) in targets().items():
        if args.target != 'all' and args.target != consumer:
            continue
        if root.is_symlink() or (present(root) and not root.is_dir()):
            raise SystemExit(f'Existing skill root is not a real directory; leaving it unchanged: {root}')
        counts[consumer] = 0
        for skill in skills:
            for source in sorted(skill.rglob('*')):
                if source.is_symlink():
                    raise SystemExit(f'Source snapshot contains a symlink: {source}')
                if not source.is_file():
                    continue
                target = root / source.relative_to(SOURCE)
                inspect_target(root, target)
                if present(target) and target.is_dir():
                    raise SystemExit(f'Refusing to replace a directory with a skill file: {target}')
                if mode == 'copy' and target.is_file() and not target.is_symlink() and digest(target) == digest(source):
                    continue
                if mode == 'link' and target.is_symlink() and target.readlink() == source:
                    continue
                plans.append((source, target, mode))
                counts[consumer] += 1
    for consumer, count in counts.items():
        print(f'{consumer}: {count} file(s) to synchronize')
    if args.dry_run or not plans:
        print(f'{len(skills)} skill folders; ' + ('dry run only.' if args.dry_run else 'already synchronized.'))
        return
    state = Path(os.environ.get('XDG_STATE_HOME', str(Path.home() / '.local/state')))
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    backup = state / 'dotfiles-wsl/agent-skills' / stamp
    backup.mkdir(parents=True)
    manifest = {'home': str(Path.home()), 'files': []}
    path = backup / 'manifest.json'
    def save():
        path.write_text(json.dumps(manifest, indent=2) + '\n')
    save()
    for index, (source, target, mode) in enumerate(plans):
        saved = backup / f'file-{index}' if present(target) else None
        manifest['files'].append({'target': str(target), 'source': str(source), 'mode': mode,
                                  'sha256': digest(source), 'backup': str(saved) if saved else None})
        save()
        target.parent.mkdir(parents=True, exist_ok=True)
        if saved:
            shutil.move(str(target), str(saved))
        if mode == 'link':
            target.symlink_to(source)
        else:
            with tempfile.NamedTemporaryFile(dir=target.parent, prefix='.skill-', delete=False) as stream:
                temporary = Path(stream.name)
            shutil.copy2(source, temporary)
            os.replace(temporary, target)
    print(f'{len(skills)} skill folders synchronized. Backup manifest: {path}')


def restore(args):
    path = Path(args.restore)
    manifest = json.loads(path.read_text())
    if manifest['home'] != str(Path.home()):
        raise SystemExit('This skill backup belongs to a different HOME.')
    if manifest.get('restored'):
        print('Already restored.')
        return
    for entry in manifest['files']:
        target = Path(entry['target'])
        if not present(target):
            continue
        correct = (target.is_symlink() and str(target.readlink()) == entry['source']) if entry['mode'] == 'link' else (target.is_file() and not target.is_symlink() and digest(target) == entry['sha256'])
        if not correct:
            raise SystemExit(f'Skill changed since installation; refusing to overwrite it: {target}')
    if args.dry_run:
        print(f"Would restore {len(manifest['files'])} managed files.")
        return
    for entry in reversed(manifest['files']):
        target = Path(entry['target'])
        if present(target):
            target.unlink()
        if entry['backup'] and present(Path(entry['backup'])):
            shutil.move(entry['backup'], str(target))
    manifest['restored'] = True
    path.write_text(json.dumps(manifest, indent=2) + '\n')
    print('Skill files restored; unrelated skills and directory roots were retained.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--target', choices=['all', *targets()], default='all')
    parser.add_argument('--restore', help='restore a backup manifest, preserving later edits')
    args = parser.parse_args()
    (restore if args.restore else install)(args)


if __name__ == '__main__':
    main()
