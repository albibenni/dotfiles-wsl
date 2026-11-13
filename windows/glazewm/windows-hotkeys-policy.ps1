[CmdletBinding(SupportsShouldProcess=$true)]
param([switch]$Restore)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$backup = Join-Path $env:LOCALAPPDATA 'dotfiles-wsl\glazewm-windows-hotkeys-policy-backup.json'
$entries = @(
    @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoWinKeys' },
    @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'DisableLockWorkstation' }
)
if ($Restore) {
    if (!(Test-Path -LiteralPath $backup -PathType Leaf)) { throw "Backup not found: $backup" }
    $saved = @(Get-Content -LiteralPath $backup -Raw | ConvertFrom-Json)
    if ($PSCmdlet.ShouldProcess('Windows shortcut policies', 'Restore original values')) {
        foreach ($entry in $saved) {
            if ($entry.Exists) {
                if (!(Test-Path -LiteralPath $entry.Path)) { New-Item -Path $entry.Path -Force | Out-Null }
                New-ItemProperty -LiteralPath $entry.Path -Name $entry.Name -Value ([int]$entry.Value) -PropertyType DWord -Force | Out-Null
            } elseif (Test-Path -LiteralPath $entry.Path) {
                Remove-ItemProperty -LiteralPath $entry.Path -Name $entry.Name -ErrorAction SilentlyContinue
            }
        }
        Remove-Item -LiteralPath $backup
        Write-Host 'Restored saved policies. Sign out and back in.'
    }
    return
}
$snapshot = foreach ($entry in $entries) {
    $item = Get-Item -LiteralPath $entry.Path -ErrorAction SilentlyContinue
    $exists = $null -ne $item -and @($item.GetValueNames()) -contains $entry.Name
    if ($exists -and $item.GetValueKind($entry.Name) -ne [Microsoft.Win32.RegistryValueKind]::DWord) {
        throw "Unexpected registry type for $($entry.Name); no changes made."
    }
    @{ Path = $entry.Path; Name = $entry.Name; Exists = $exists; Value = $(if ($exists) { $item.GetValue($entry.Name) } else { $null }) }
}
if ($PSCmdlet.ShouldProcess('Windows shortcut policies', 'Disable Windows hotkeys and workstation locking')) {
    if (!(Test-Path -LiteralPath $backup)) {
        New-Item -ItemType Directory -Path (Split-Path $backup -Parent) -Force | Out-Null
        ConvertTo-Json -InputObject @($snapshot) | Set-Content -LiteralPath $backup -Encoding UTF8
    }
    foreach ($entry in $entries) {
        if (!(Test-Path -LiteralPath $entry.Path)) { New-Item -Path $entry.Path -Force | Out-Null }
        New-ItemProperty -LiteralPath $entry.Path -Name $entry.Name -Value 1 -PropertyType DWord -Force | Out-Null
    }
    Write-Host "Policies updated. Backup: $backup. Sign out and back in."
}
