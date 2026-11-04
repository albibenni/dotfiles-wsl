#!/usr/bin/env python3
"""Set one Windows Terminal profile's font, retaining other settings and a backup."""
import argparse
import datetime
import json
import os
from pathlib import Path
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--settings', type=Path, required=True, help='WSL path to Windows Terminal settings.json')
    parser.add_argument('--profile', default='Ubuntu-26.04', help='profile name or GUID')
    parser.add_argument('--size', type=int, default=14)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    if not 6 <= args.size <= 72:
        parser.error('--size must be between 6 and 72')
    raw = args.settings.read_bytes()
    try:
        settings = json.loads(raw.decode('utf-8-sig'))
    except json.JSONDecodeError as error:
        parser.error(f'Expected plain JSON; leave JSONC/commented settings unchanged and edit the font manually: {error}')
    matches = [p for p in settings.get('profiles', {}).get('list', []) if args.profile in (p.get('name'), p.get('guid'))]
    if len(matches) != 1:
        parser.error(f'Expected one matching profile; found {len(matches)}')
    profile = matches[0]
    preset_path = Path(__file__).resolve().parents[1] / 'windows-terminal/ubuntu-font.json'
    desired = json.loads(preset_path.read_text())['font']
    desired['size'] = args.size
    old = dict(profile.get('font', {}))
    new = dict(old, **desired)
    print(f"{profile.get('name')}: {old} -> {new}")
    if args.dry_run or old == new:
        return
    profile['font'] = new
    serialized = json.dumps(settings, ensure_ascii=False, indent=4) + '\n'
    if b'\r\n' in raw:
        serialized = serialized.replace('\n', '\r\n')
    encoded = (b'\xef\xbb\xbf' if raw.startswith(b'\xef\xbb\xbf') else b'') + serialized.encode('utf-8')
    if args.settings.read_bytes() != raw:
        raise SystemExit('Settings changed during preparation; retry without overwriting concurrent edits.')
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    backup = args.settings.with_name(args.settings.name + '.dotfiles-wsl-backup-' + stamp)
    backup.write_bytes(raw)
    with tempfile.NamedTemporaryFile(dir=args.settings.parent, prefix='.font-update-', delete=False) as stream:
        temporary = Path(stream.name)
        stream.write(encoded)
    os.replace(temporary, args.settings)
    print(f'Backup: {backup}')
    print('Open a fresh tab using this profile. Text and icons both use the larger font.')


if __name__ == '__main__':
    main()
