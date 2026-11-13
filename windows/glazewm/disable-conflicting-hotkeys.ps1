[CmdletBinding(SupportsShouldProcess=$true)]
param([switch]$Restore)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Explorer's per-key setting also affects other Win combinations using these keys.
$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$name = 'DisabledHotkeys'
$backup = Join-Path $env:LOCALAPPDATA 'dotfiles-wsl\glazewm-disabled-hotkeys-backup.json'
$keys = '0123456789FHJKOTW'
$registry = Get-Item -LiteralPath $path
$exists = @($registry.GetValueNames()) -contains $name

if ($Restore) {
    if (!(Test-Path -LiteralPath $backup -PathType Leaf)) { throw "Backup not found: $backup" }
    $saved = Get-Content -LiteralPath $backup -Raw | ConvertFrom-Json
    if ($PSCmdlet.ShouldProcess($path, 'Restore DisabledHotkeys from backup')) {
        if ($saved.exists) {
            New-ItemProperty -LiteralPath $path -Name $name -Value ([string]$saved.value) -PropertyType String -Force | Out-Null
        } elseif ($exists) {
            Remove-ItemProperty -LiteralPath $path -Name $name
        }
        Remove-Item -LiteralPath $backup
        Write-Host 'Restored the original value. Sign out and back in.'
    }
    return
}

if ($exists -and $registry.GetValueKind($name) -ne [Microsoft.Win32.RegistryValueKind]::String) {
    throw 'Existing DisabledHotkeys is not a string; no changes made.'
}
$current = if ($exists) { [string]$registry.GetValue($name) } else { '' }
$updated = $current
foreach ($key in $keys.ToCharArray()) {
    if ($updated.IndexOf([string]$key, [StringComparison]::OrdinalIgnoreCase) -lt 0) { $updated += $key }
}
if ($updated -ceq $current) { Write-Host 'The requested keys are already present; no changes made.'; return }
if ($PSCmdlet.ShouldProcess($path, "Add $keys to DisabledHotkeys")) {
    if (!(Test-Path -LiteralPath $backup)) {
        New-Item -ItemType Directory -Path (Split-Path $backup -Parent) -Force | Out-Null
        @{ exists = $exists; value = $current } | ConvertTo-Json | Set-Content -LiteralPath $backup -Encoding UTF8
    }
    New-ItemProperty -LiteralPath $path -Name $name -Value $updated -PropertyType String -Force | Out-Null
    Write-Host "Updated DisabledHotkeys. Backup: $backup. Sign out and back in."
}
