[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$Distro = 'Ubuntu',
    [switch]$EnableStartup,
    [switch]$SkipPackages,
    [ValidateRange(30,1800)][int]$TimeoutSeconds = 600
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
function Find-Rancher {
    foreach ($root in @("$env:LOCALAPPDATA\Programs\Rancher Desktop", "$env:ProgramFiles\Rancher Desktop")) {
        if (Test-Path -LiteralPath "$root\Rancher Desktop.exe") { return $root }
    }
    return $null
}
function Invoke-DistroScript([string]$Script) {
    # Base64 avoids Windows PowerShell 5.1 stripping quotes in sh -c arguments.
    $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Script))
    & wsl.exe -d $Distro -u root -- sh -c "echo $encoded | base64 -d | sh"
    if ($LASTEXITCODE -ne 0) { throw "WSL preflight/service operation failed ($LASTEXITCODE)." }
}
$root = Find-Rancher
if ($WhatIfPreference) {
    Write-Host "Would validate WSL2 distro $Distro and refuse running native Docker containers."
    if (!$root -and !$SkipPackages) { Write-Host 'Would install winget package SUSE.RancherDesktop.' }
    Write-Host 'Would stop and disable native docker.service and docker.socket (systemd required).'
    Write-Host "Would start Rancher with Moby, enable integration for $Distro, and verify its Docker server."
    if ($EnableStartup) { Write-Host 'Would enable Rancher Desktop at Windows sign-in.' }
    return
}
if (!$PSCmdlet.ShouldProcess($Distro, 'Install/configure Rancher Desktop and disable native Docker')) { return }
# Avoid inheriting a UNC working directory from WSL.
Set-Location $env:USERPROFILE
if (Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue) { throw 'Quit Docker Desktop before running this installer.' }
Invoke-DistroScript 'uname -r | grep -qi WSL2 && test -d /run/systemd/system && command -v systemctl >/dev/null && test -e /proc/sys/fs/binfmt_misc/WSLInterop'
if ($LASTEXITCODE -ne 0) { throw 'An existing WSL2 distro with systemd and Windows interop is required. See docs/rancher-desktop.md.' }
# Only interrogate the native engine when its service is active. Never stop workloads implicitly.
Invoke-DistroScript 'if systemctl is-active --quiet docker.service; then ids=$(docker -H unix:///var/run/docker.sock ps -q) || exit 2; if [ -n "$ids" ]; then echo "Stop native Docker containers before switching to Rancher Desktop." >&2; exit 3; fi; fi'
if ($LASTEXITCODE -ne 0) { throw 'Native Docker preflight failed; no services were changed.' }
if (!$root) {
    if ($SkipPackages) { throw 'Rancher Desktop is not installed. Remove -SkipPackages.' }
    & winget.exe install --id SUSE.RancherDesktop --exact --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity
    if ($LASTEXITCODE -ne 0) { throw "winget failed ($LASTEXITCODE). Native Docker was not changed. Reboot if the installer requests it." }
    $root = Find-Rancher
    if (!$root) { throw 'Rancher Desktop executable not found after installation.' }
}
$cli = Join-Path $root 'resources\resources\win32\bin\rdctl.exe'
if (!(Test-Path -LiteralPath $cli)) { throw "Missing Rancher CLI: $cli" }
# Missing units are normal on fresh distros; genuine stop/disable failures are fatal.
Invoke-DistroScript 'for unit in docker.socket docker.service; do state=$(systemctl show -p LoadState --value "$unit") || exit; if [ "$state" != not-found ]; then systemctl disable --now "$unit" || exit; fi; done'
if ($LASTEXITCODE -ne 0) { throw 'Could not disable native Docker. Check systemctl status docker.service docker.socket.' }
$startArgs = @('start', '--container-engine.name=moby', '--wait', "--wait-timeout=$($TimeoutSeconds)s")
if ($EnableStartup) { $startArgs += '--application.auto-start=true' }
& $cli @startArgs
if ($LASTEXITCODE -ne 0) { throw "Rancher startup failed. See $env:LOCALAPPDATA\rancher-desktop\logs. Native Docker remains disabled; see rollback instructions." }
$settingsText = & $cli list-settings
if ($LASTEXITCODE -ne 0) { throw 'Could not read Rancher settings.' }
$settings = ($settingsText -join "`n") | ConvertFrom-Json
# Partial API updates preserve integration settings for other distributions.
$payload = @{version=$settings.version; WSL=@{integrations=@{$Distro=$true}}}
$temp = [IO.Path]::GetTempFileName()
try {
    [IO.File]::WriteAllText($temp, ($payload | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))
    & $cli api /v1/settings --method PUT --input $temp
    if ($LASTEXITCODE -ne 0) { throw 'Could not enable WSL integration.' }
} finally { Remove-Item -LiteralPath $temp -Force }
$deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
Write-Host 'Waiting for the Rancher Docker server in WSL...'
do {
    # Explicit endpoint avoids stale Docker contexts and DOCKER_HOST overrides.
    & wsl.exe -d $Distro -u root -- docker -H unix:///var/run/docker.sock info --format 'Server={{.ServerVersion}} Name={{.Name}}'
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Rancher Desktop ready; WSL integration enabled for $Distro."
        Write-Host 'Native Docker is disabled. Existing native Docker data has not been migrated or deleted.'
        return
    }
    Start-Sleep -Seconds 3
} while ([DateTime]::UtcNow -lt $deadline)
throw "Docker integration did not become ready. Inspect $env:LOCALAPPDATA\rancher-desktop\logs and check that the Docker CLI is installed in $Distro."
