"""Offline checks for config syntax and reversible setup behavior."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import tomllib

ROOT = Path(__file__).resolve().parents[1]
for path in ROOT.rglob('*'):
    if path.is_file() and '.git' not in path.parts and '__pycache__' not in path.parts:
        assert b'\r\n' not in path.read_bytes(), f'CRLF: {path}'
for path in ROOT.rglob('*.toml'):
    tomllib.loads(path.read_text())

with tempfile.TemporaryDirectory(prefix='dotfiles-wsl-test-') as temp:
    home = Path(temp)
    config = home / '.config'
    config.mkdir()
    (config / 'nvim').mkdir()
    (config / 'nvim/original').write_text('keep editor config\n')
    (config / 'starship.toml').write_text('# original prompt\n')
    rc = home / '.bashrc'
    original = '# corporate startup\nkerberos_ticket_check\n'
    rc.write_text(original)
    env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(config),
               XDG_STATE_HOME=str(home / '.local/state'), XDG_DATA_HOME=str(home / '.local/share'),
               XDG_CACHE_HOME=str(home / '.cache'), GIT_CONFIG_GLOBAL=str(home / '.gitconfig'),
               GIT_CONFIG_NOSYSTEM='1')
    def run(*args, ok=True):
        result = subprocess.run(args, env=env, capture_output=True, text=True)
        if ok and result.returncode:
            raise AssertionError(f'{args}\n{result.stdout}\n{result.stderr}')
        return result
    run(str(ROOT / 'scripts/setup.sh'), '--dry-run', '--git')
    assert rc.read_text() == original
    assert not (home / '.local/state').exists()
    run(str(ROOT / 'scripts/setup.sh'), '--git')
    assert (config / 'nvim').resolve() == ROOT / 'config/nvim'
    assert rc.read_text().startswith(original)
    assert 'kerberos_ticket_check' in rc.read_text()
    run(str(ROOT / 'scripts/setup.sh'), '--git')
    assert rc.read_text().count('# >>> dotfiles-wsl >>>') == 1
    manifests = list((home / '.local/state').rglob('manifest.json'))
    assert len(manifests) == 1
    rc.write_text(rc.read_text() + '# user edit after setup\n')
    # Simulate a user replacing a managed symlink; restore must stop before changes.
    link = config / 'nvim'
    link.unlink()
    link.mkdir()
    result = run(str(ROOT / 'scripts/restore.sh'), str(manifests[0]), ok=False)
    assert result.returncode != 0 and 'Refusing' in result.stderr
    assert (config / 'starship.toml').is_symlink()
    link.rmdir()
    link.symlink_to(ROOT / 'config/nvim')
    run(str(ROOT / 'scripts/restore.sh'), str(manifests[0]), '--dry-run')
    assert link.is_symlink()
    run(str(ROOT / 'scripts/restore.sh'), str(manifests[0]))
    assert (config / 'nvim/original').read_text() == 'keep editor config\n'
    assert (config / 'starship.toml').read_text() == '# original prompt\n'
    assert rc.read_text() == original + '# user edit after setup\n'
    assert not (config / 'dotfiles-wsl').exists()
    result = run('git', 'config', '--global', '--get-all', 'include.path', ok=False)
    assert str(ROOT / 'config/git/config') not in result.stdout
    run(str(ROOT / 'scripts/restore.sh'), str(manifests[0]))
    # Source our Bash loader in isolation, never the real corporate .bashrc.
    old_path = env['PATH']
    env['PATH'] = '/usr/bin:/bin'
    run('bash', '--noprofile', '--norc', '-ic', 'source "$1"; test -n "$DOTFILES_WSL"; type cdf >/dev/null', 'test', str(ROOT / 'config/bash/init.sh'))
    env['PATH'] = old_path
    # Exercise imported Bash behavior without sourcing corporate startup or network tools.
    bash_bin = home / 'bash-test-bin'
    bash_bin.mkdir()
    (bash_bin / 'kubectl').write_text('#!/bin/sh\nprintf "kubectl\\n" >> "$HOME/completion-calls"\nprintf "__start_kubectl() { :; }\\n"\n')
    (bash_bin / 'kubectl').chmod(0o755)
    for app, emitted in (('try', '_test_try_ready=1'), ('task-planner', '_test_task_ready=1')):
        (bash_bin / app).write_text(f'#!/bin/sh\nprintf "{app}\\n" >> "$HOME/completion-calls"\nprintf "{emitted}\\n"\n')
        (bash_bin / app).chmod(0o755)
    (home / 'A directory').mkdir()
    (home / 'z-target').mkdir()
    # A full .bashrc reload would create this marker; the layer reload must not.
    rc.write_text('touch "$HOME/corporate-reran"\n')
    bash_test = home / 'check-bash.sh'
    bash_test.write_text(r"""
set -e
export EDITOR=custom-editor MANPAGER=less
source "$1"
[[ $EDITOR == custom-editor && $MANPAGER == less ]]
[[ $DOTFILES == "$DOTFILES_WSL" && $- != *h* ]]
first_path=$PATH
# fzf runs previews in a child shell, where a Bash-only bat alias is unavailable.
fzf() { printf '%s\n' "$@" > "$HOME/fzf-preview-args"; }
ff
unset -f fzf
if ! type -P bat >/dev/null && type -P batcat >/dev/null; then
    command grep -q batcat "$HOME/fzf-preview-args"
fi
[[ $(alias vim) == "alias vim='nvim'" ]]
[[ $(alias cd) == "alias cd='zd'" ]]
zd "$HOME/A directory"
[[ $PWD == "$HOME/A directory" ]]
zd -- "$HOME/z-target"
[[ $PWD == "$HOME/z-target" ]]
zd - >/dev/null
[[ $PWD == "$HOME/A directory" ]]
zd -P "$HOME/z-target"
[[ $PWD == "$HOME/z-target" ]]
z() { [[ $1 == fuzzy-project ]]; builtin cd -- "$HOME/A directory"; }
zd fuzzy-project
[[ $PWD == "$HOME/A directory" ]]
# Pull/push helpers pass the current branch and arguments without running real Git.
git() {
    if [[ $1 == branch ]]; then printf 'feature/example\n';
    else printf '%s\n' "$@" >> "$HOME/git-arguments"; fi
}
ggpull --ff-only
ggpush --dry-run
unset -f git
_reload_bashrc
[[ $PATH == "$first_path" && ! -e $HOME/corporate-reran ]]
[[ $_test_try_ready == 1 && $_test_task_ready == 1 ]]
complete -p k | command grep -q __start_kubectl
bind -X | command grep -Fq '_reload_bashrc'
bind -v | command grep -Fq 'set page-completions off'
""".lstrip())
    env['PATH'] = str(bash_bin) + ':/usr/bin:/bin'
    result = run('bash', '--noprofile', '--norc', '-i', str(bash_test), str(ROOT / 'config/bash/init.sh'))
    assert 'unknown variable' not in result.stderr and 'command not found' not in result.stderr, result.stderr
    assert not (home / 'corporate-reran').exists()
    assert sorted((home / 'completion-calls').read_text().splitlines()) == ['kubectl', 'task-planner', 'try']
    assert (home / 'git-arguments').read_text().splitlines() == ['pull', 'origin', 'feature/example', '--ff-only', 'push', 'origin', 'feature/example', '--dry-run']
    # Local overrides are last and can opt out of any imported alias/default.
    overrides = config / 'dotfiles-wsl.local.sh'
    overrides.write_text("export EDITOR=local-editor\nalias cd='builtin cd'\n")
    run('bash', '--noprofile', '--norc', '-ic', 'source "$1"; [[ $EDITOR == local-editor ]]; [[ $(alias cd) == "alias cd=\'builtin cd\'" ]]', 'test', str(ROOT / 'config/bash/init.sh'))
    overrides.unlink()
    env['PATH'] = old_path
    # Load the base Neovim config without downloading any plugins or touching real HOME.
    env['DOTFILES_WSL_OFFLINE'] = '1'
    run('nvim', '--headless', '-u', str(ROOT / 'config/nvim/init.lua'), '+qa')
    # Exercise picker argument quoting and attach/switch logic with a fake tmux.
    fake = home / 'fake-bin'
    fake.mkdir()
    log = home / 'tmux-log'
    (fake / 'tmux').write_text('#!/usr/bin/env python3\nimport json, os, sys\nwith open(os.environ["TMUX_TEST_LOG"], "a") as f: f.write(json.dumps(sys.argv[1:]) + "\\n")\nif sys.argv[1] == "has-session": sys.exit(1)\n')
    (fake / 'tmux').chmod(0o755)
    env['PATH'] = str(fake) + ':' + env['PATH']
    env['TMUX_TEST_LOG'] = str(log)
    env.pop('TMUX', None)
    project = home / 'Project with spaces'
    project.mkdir()
    run(str(ROOT / 'bin/tmux-sessionizer'), str(project))
    calls = [json.loads(line) for line in log.read_text().splitlines()]
    assert calls[1][-2:] == ['-c', str(project)]
    assert calls[-1][0] == 'attach-session'
    first_name = calls[-1][-1]
    log.write_text('')
    env['TMUX'] = '/tmp/fake,1,0'
    run(str(ROOT / 'bin/tmux-sessionizer'), str(project))
    calls = [json.loads(line) for line in log.read_text().splitlines()]
    assert calls[-1][0] == 'switch-client' and calls[-1][-1] == first_name
    # Different directories with the same basename must use separate sessions.
    other = home / 'another' / project.name
    other.mkdir(parents=True)
    log.write_text('')
    run(str(ROOT / 'bin/tmux-sessionizer'), str(other))
    calls = [json.loads(line) for line in log.read_text().splitlines()]
    assert calls[-1][-1] != first_name
    # Test mise merging without downloading tools or changing real configuration.
    (fake / 'mise').write_text('#!/usr/bin/env python3\nimport json, os, sys\nwith open(os.environ["TMUX_TEST_LOG"], "a") as f: f.write(json.dumps(sys.argv[1:]) + "\\n")\n')
    (fake / 'mise').chmod(0o755)
    mise_config = config / 'mise/config.toml'
    mise_config.parent.mkdir()
    mise_config.write_text('[tools]\nnode = "22"\n"npm:prettier" = "3"\n')
    env['MISE_GLOBAL_CONFIG_FILE'] = str(mise_config)
    log.write_text('')
    result = run(str(ROOT / 'scripts/install-tools.sh'), '--dry-run')
    assert 'use --global node@' not in result.stdout
    assert 'use --global npm:prettier@' not in result.stdout
    assert 'npm:pyright@latest' in result.stdout
    assert not log.read_text(), 'dry-run invoked mise'
    run(str(ROOT / 'scripts/install-tools.sh'))
    calls = [json.loads(line) for line in log.read_text().splitlines()]
    use = [call for call in calls if 'use' in call]
    assert len(use) == 4 and not any(call[-1].startswith(('node@', 'npm:prettier@')) for call in use)
    assert mise_config.read_text() == '[tools]\nnode = "22"\n"npm:prettier" = "3"\n'
    mise_config.write_text('broken [ TOML')
    log.write_text('')
    assert run(str(ROOT / 'scripts/install-tools.sh'), ok=False).returncode != 0
    assert not log.read_text(), 'malformed TOML must stop before invoking mise'
    # Verify Windows clipboard encoding through a fake executable, not the clipboard.
    env['PATH'] = str(fake) + ':/usr/bin:/bin'
    (fake / 'clip.exe').write_text('#!/usr/bin/env python3\nimport os, pathlib, sys\npathlib.Path(os.environ["TMUX_TEST_LOG"]).write_bytes(sys.stdin.buffer.read())\n')
    (fake / 'clip.exe').chmod(0o755)
    content = 'Unicode: café 日本語 🐧\n'
    result = subprocess.run([str(ROOT / 'bin/clipboard-copy')], input=content.encode(), env=env, capture_output=True)
    assert result.returncode == 0, result.stderr
    assert log.read_bytes().decode('utf-16le') == content
print('Offline checks passed: setup/restore, Bash aliases/reload/overrides, Neovim, session picker, mise preservation, clipboard encoding.')
