"""Exercise skill copies/links, backups, idempotence and conflict protection offline."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='wsl-skills-test-') as directory:
    home = Path(directory)
    env = dict(os.environ, HOME=str(home), CODEX_HOME=str(home / '.codex'), XDG_CONFIG_HOME=str(home / '.config'), XDG_STATE_HOME=str(home / '.local/state'))
    codex = home / '.codex/skills'
    (codex / '.system').mkdir(parents=True)
    (codex / '.system/keep').write_text('builtin')
    (codex / 'adaptive-tdd').mkdir()
    old = codex / 'adaptive-tdd/SKILL.md'
    old.write_text('my earlier skill')
    shared = home / '.agents/skills'
    (shared / 'unrelated').mkdir(parents=True)
    (shared / 'unrelated/SKILL.md').write_text('unrelated')
    (shared / 'explain').mkdir()
    original = home / 'my-original-skill'
    original.write_text('linked user skill')
    linked = shared / 'explain/SKILL.md'
    linked.symlink_to(original)
    def run(*args, ok=True):
        result = subprocess.run(['python3',str(ROOT/'scripts/install-agent-skills.py'),*args],env=env,capture_output=True,text=True)
        if ok and result.returncode: raise AssertionError(result.stderr + result.stdout)
        return result
    run('--dry-run')
    assert old.read_text() == 'my earlier skill' and not (home/'.gemini').exists()
    run()
    assert not old.is_symlink() and old.read_bytes() == (ROOT/'agent/skills/adaptive-tdd/SKILL.md').read_bytes()
    assert linked.is_symlink() and linked.resolve() == ROOT/'agent/skills/explain/SKILL.md'
    assert (codex/'.system/keep').read_text() == 'builtin'
    manifests = list((home/'.local/state').rglob('manifest.json'))
    assert len(manifests) == 1
    run()
    assert len(list((home/'.local/state').rglob('manifest.json'))) == 1
    old.write_text('edit after installation')
    assert run('--restore',str(manifests[0]),ok=False).returncode != 0
    assert linked.is_symlink()
    shutil.copy2(ROOT/'agent/skills/adaptive-tdd/SKILL.md',old)
    run('--restore',str(manifests[0]),'--dry-run')
    assert old.read_text() != 'my earlier skill'
    run('--restore',str(manifests[0]))
    assert old.read_text() == 'my earlier skill'
    assert linked.readlink() == original and original.read_text() == 'linked user skill'
    assert (shared/'unrelated/SKILL.md').read_text() == 'unrelated'
    assert (codex/'.system/keep').read_text() == 'builtin'
    shared.rename(home/'.agents/saved')
    shared.symlink_to(home/'.agents/saved',target_is_directory=True)
    assert run(ok=False).returncode != 0
    assert shared.is_symlink() and old.read_text() == 'my earlier skill'
print('Skills: copies/links, backups, repeated install, restore, later edits and symlink roots passed.')
