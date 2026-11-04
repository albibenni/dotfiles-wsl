#!/usr/bin/env python3
"""Install the pinned Linux JDTLS distribution without root or Mason."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import tarfile
import tempfile
import urllib.request


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--archive', type=Path, help='use an already downloaded archive after verifying its checksum')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    lock = json.loads((repo / 'config/java/jdtls.json').read_text())
    base = Path(os.environ.get('XDG_DATA_HOME', str(Path.home() / '.local/share'))) / 'dotfiles-wsl/jdtls'
    destination = base / lock['version']
    if args.dry_run:
        print(f"Install JDTLS {lock['version']} from {lock['url']} into {destination}")
        return
    base.mkdir(parents=True, exist_ok=True)
    marker = destination / '.dotfiles-sha256'
    if destination.exists():
        if not marker.exists() or marker.read_text().strip() != lock['sha256']:
            raise SystemExit(f'Refusing to replace an unknown JDTLS installation: {destination}')
    else:
        with tempfile.TemporaryDirectory(prefix='.jdtls-', dir=base) as temp:
            staging = Path(temp)
            archive = args.archive
            if archive is None:
                archive = staging / 'jdtls.tar.gz'
                with urllib.request.urlopen(lock['url'], timeout=120) as response, archive.open('wb') as output:
                    shutil.copyfileobj(response, output)
            if hashlib.sha256(archive.read_bytes()).hexdigest() != lock['sha256']:
                raise SystemExit('JDTLS archive checksum mismatch; nothing installed.')
            unpacked = staging / 'unpacked'
            unpacked.mkdir()
            with tarfile.open(archive) as tar:
                tar.extractall(unpacked, filter='data')
            if not (unpacked / 'config_linux/config.ini').exists() or len(list((unpacked / 'plugins').glob('org.eclipse.equinox.launcher_*.jar'))) != 1:
                raise SystemExit('Unexpected Linux JDTLS archive layout.')
            (unpacked / '.dotfiles-version').write_text(lock['version'] + '\n')
            (unpacked / '.dotfiles-sha256').write_text(lock['sha256'] + '\n')
            unpacked.rename(destination)
    current = base / 'current'
    if current.exists() and not current.is_symlink():
        raise SystemExit(f'Refusing to replace a non-symlink: {current}')
    temporary = base / f'.current-{os.getpid()}'
    temporary.symlink_to(destination, target_is_directory=True)
    os.replace(temporary, current)
    print(f"JDTLS {lock['version']} installed; server JDK: {lock['java']}")


if __name__ == '__main__':
    main()
