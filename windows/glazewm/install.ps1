[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [string]$Distro = 'Ubuntu-26.04',
    [switch]$Start,
    [switch]$EnableStartup,
    [switch]$SkipPackages,
    [string]$ConfigDirectory = (Join-Path $env:USERPROFILE '.glzr\glazewm')
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$template = Join-Path $repo 'config\glazewm\config.yaml'
if (!(Test-Path -LiteralPath $template -PathType Leaf)) { throw "Missing template: $template" }
if ($Distro -notmatch '^[A-Za-z0-9_.-]+$') { throw 'Use the exact WSL distro name (letters, digits, dots, underscores, hyphens).' }
$config = [IO.File]::ReadAllText($template).Replace('{{WSL_DISTRO}}', $Distro)
$utf8 = New-Object Text.UTF8Encoding($false)
function Find-GlazeWM {
    $candidates = @(
        (Join-Path $env:ProgramFiles 'glzr.io\GlazeWM\glazewm.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\glzr.io\GlazeWM\glazewm.exe')
    )
    $cmd = Get-Command glazewm.exe -ErrorAction SilentlyContinue
    if ($cmd) { $candidates += $cmd.Source }
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) {
            if ((Split-Path (Split-Path $p -Parent) -Leaf) -eq 'cli') { return Join-Path (Split-Path (Split-Path $p -Parent) -Parent) 'glazewm.exe' }
            return $p
        }
    }
    return $null
}
$exe = Find-GlazeWM
if ($WhatIfPreference) {
    if (!$exe -and !$SkipPackages) { Write-Host 'Would install winget glzr-io.glazewm (standalone; Custom_InstallZebar=0).' }
    Write-Host "Would back up changed files and copy config + cheat sheet to $ConfigDirectory (distro $Distro)."
    if ($EnableStartup) { Write-Host 'Would create per-user Startup shortcut Dotfiles-GlazeWM.lnk.' }
    if ($Start) { Write-Host 'Would start GlazeWM, or reload an existing instance.' }
    return
}
if (!$PSCmdlet.ShouldProcess($ConfigDirectory, 'Install GlazeWM configuration')) { return }
# Refuse to traverse junctions/symlinks at any destination directory component.
$check = [IO.DirectoryInfo]([IO.Path]::GetFullPath($ConfigDirectory))
while ($null -ne $check) {
    if ($check.Exists -and ($check.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "Refusing reparse-point directory: $($check.FullName)" }
    $check = $check.Parent
}
if (!$exe) {
    if ($SkipPackages) { throw 'GlazeWM is not installed. Remove -SkipPackages or install it first.' }
    if (!(Get-Command winget.exe -ErrorAction SilentlyContinue)) { throw 'Install Windows App Installer (winget) first.' }
    # WiX Burn's official variable excludes the optional Zebar package.
    & winget.exe install --id glzr-io.glazewm --exact --source winget --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --override '/quiet /norestart Custom_InstallZebar=0'
    if ($LASTEXITCODE -ne 0) { throw "winget failed ($LASTEXITCODE). Configuration was not changed." }
    $exe = Find-GlazeWM
    if (!$exe) { throw 'GlazeWM installation completed but executable was not found.' }
}
$backup = Join-Path $env:LOCALAPPDATA ('dotfiles-wsl\glazewm-backups\' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffffffZ'))
function Save-Existing([string]$path, [string]$name) {
    if (Test-Path -LiteralPath $path) {
        $item = Get-Item -LiteralPath $path -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Refusing to replace a symlink: $path" }
        if ($item.PSIsContainer) { throw "Expected a file: $path" }
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
        Copy-Item -LiteralPath $path -Destination (Join-Path $backup $name)
    }
}
New-Item -ItemType Directory -Path $ConfigDirectory -Force | Out-Null
$files = @{
    'config.yaml' = $config
    'KEYBINDINGS.txt' = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'KEYBINDINGS.txt')).Replace('{{WSL_DISTRO}}', $Distro)
}
# Validate every managed destination before modifying any files.
foreach ($name in $files.Keys) {
    $dest = Join-Path $ConfigDirectory $name
    if (Test-Path -LiteralPath $dest) {
        $item = Get-Item -LiteralPath $dest -Force
        if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "Refusing non-regular destination: $dest" }
    }
}
foreach ($name in $files.Keys) {
    $dest = Join-Path $ConfigDirectory $name
    if ((Test-Path -LiteralPath $dest) -and [IO.File]::ReadAllText($dest) -ceq $files[$name]) { continue }
    Save-Existing $dest $name
    [IO.File]::WriteAllText($dest, $files[$name], $utf8)
    Write-Host "Updated $dest"
}
$configPath = Join-Path $ConfigDirectory 'config.yaml'
if ($EnableStartup) {
    $link = Join-Path ([Environment]::GetFolderPath('Startup')) 'Dotfiles-GlazeWM.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($link)
    $arguments = 'start --config "' + $configPath + '"'
    if ($shortcut.TargetPath -ne $exe -or $shortcut.Arguments -ne $arguments) {
        Save-Existing $link 'Dotfiles-GlazeWM.lnk'
        $shortcut.TargetPath = $exe
        $shortcut.Arguments = $arguments
        $shortcut.WorkingDirectory = Split-Path $exe -Parent
        $shortcut.Description = 'Hyprland-inspired GlazeWM from dotfiles-wsl'
        $shortcut.Save()
    }
    Write-Host "Login startup enabled: $link"
}
if (Test-Path -LiteralPath $backup) { Write-Host "Backups: $backup" }
if ($Start) {
    $cli = Join-Path (Split-Path $exe -Parent) 'cli\glazewm.exe'
    $running = Get-Process glazewm -ErrorAction SilentlyContinue
    if ($running) {
        # Do not reload another config path implicitly.
        $other = @(Get-CimInstance Win32_Process -Filter "Name='glazewm.exe'" | Where-Object { $_.CommandLine -and $_.CommandLine -notlike ('*' + $configPath + '*') })
        # UIAccess-protected processes can hide CommandLine; skip only that unavailable check.
        if ($other.Count) { throw "GlazeWM is already running with another config. Exit from its tray, then rerun with -Start. Config prepared at $configPath" }
        $reload = (& $cli command wm-reload-config | ConvertFrom-Json)
        if ($LASTEXITCODE -ne 0 -or !$reload.success) { throw 'GlazeWM config reload failed.' }
    } else {
        Start-Process -FilePath $exe -ArgumentList @('start', '--config', ('"' + $configPath + '"'))
    }
    $ready = $false
    for ($attempt=0; $attempt -lt 15; $attempt++) {
        Start-Sleep -Milliseconds 500
        try {
            $status = & $cli query app-metadata 2>$null
            if ($LASTEXITCODE -eq 0 -and $status -and ($status | ConvertFrom-Json).success) { $ready = $true; break }
        } catch { # Server may still be initializing; retry briefly.
        }
    }
    if (!$ready) { throw "GlazeWM did not become ready. Check logs under $ConfigDirectory." }
    Write-Host 'GlazeWM running. Pause: Win+Ctrl+Shift+P. Exit: Win+Ctrl+Shift+Escape.'
} else { Write-Host "Prepared. Start with: & '$exe' start --config '$configPath'" }
