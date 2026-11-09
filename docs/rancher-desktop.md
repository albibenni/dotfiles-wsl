# Rancher Desktop on Windows with WSL

Run this separate installer after setting up Windows WSL2, an Ubuntu distro,
systemd, and Windows interop. Use Windows `wsl --install -d Ubuntu` on a fresh PC,
finish Ubuntu's first-run setup and reboot when requested. On older distros enable
`[boot] systemd=true` in `/etc/wsl.conf`, then restart that distro. The script does
not install WSL itself or restart your other distributions.

From your WSL checkout:

```bash
./scripts/install-rancher-desktop.sh --dry-run --startup
./scripts/install-rancher-desktop.sh --startup
# Repair an existing installation, selecting the distro explicitly:
./scripts/install-rancher-desktop.sh --skip-packages --distro Ubuntu-26.04
```

The default distro is the current `$WSL_DISTRO_NAME` (otherwise Ubuntu).
Windows PowerShell can also run the installer from a Windows or WSL checkout:

```powershell
.\windows\rancher-desktop\install.ps1 -Distro Ubuntu -WhatIf -EnableStartup
.\windows\rancher-desktop\install.ps1 -Distro Ubuntu -EnableStartup
```

The installer uses winget `SUSE.RancherDesktop` when needed, selects the Moby
(Docker-compatible) engine, starts Rancher with its supported `rdctl` CLI, enables
WSL integration, and checks Docker through the distro socket. `--startup` enables
Windows sign-in startup; omitting it preserves the existing startup preference.
Kubernetes settings and other distro integrations are preserved. Windows may ask
for installer administrator consent. Startup can take several minutes.

Quit Docker Desktop first and stop any containers using Ubuntu's native Docker.
The script refuses to proceed if native Docker has running containers or its
container list cannot be read. It disables `docker.socket` and `docker.service`
to free `/var/run/docker.sock` for Rancher's integration proxy. No socket files
are manually removed. Keep your Ubuntu Docker CLI: only its local engine is
stopped. A distro with no Docker services is supported, but Docker verification
requires a Docker CLI (install `docker.io` with apt if missing, then rerun this
installer to disable the native service that package may start).

Existing Docker Desktop and native Ubuntu Docker images, volumes and containers
are separate from Rancher's storage. This script neither migrates nor deletes
them, uninstalls Docker Desktop, resets Rancher, nor unregisters WSL distros.
If you use a custom Docker context or `DOCKER_HOST`, select Rancher's endpoint
before normal use; verification explicitly checks `/var/run/docker.sock`.

If startup fails, inspect `%LOCALAPPDATA%\rancher-desktop\logs` and the console
error. Native Docker remains disabled so the socket conflict does not recur.
To roll back, quit Rancher, turn off this distro's integration in its preferences,
then run in Ubuntu:

```bash
sudo systemctl enable --now docker.socket docker.service
```

For the observed startup failure, Rancher's Windows app was closed and its backend
was uninitialized; the earlier integration logs repeatedly reported
`bind: address already in use`. Ubuntu's systemd Docker owned the socket. Stopping
that engine and launching Rancher restored its backend and both Windows and WSL
Docker connections. A missing `/run/wsl-init.pid` during early startup alone does
not establish a corrupted installation; allow startup to complete.

References: [installation](https://docs.rancherdesktop.io/getting-started/installation/)
and [rdctl commands and settings API](https://docs.rancherdesktop.io/references/rdctl-command-reference/).
