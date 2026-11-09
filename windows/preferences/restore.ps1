#Requires -Version 5.1
#Requires -RunAsAdministrator
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('Install', 'Apply', 'Uninstall')]
    [string]$Mode = 'Install'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$directory = Join-Path $env:ProgramData 'dotfiles-wsl\preferences'
$installedScript = Join-Path $directory 'restore.ps1'
$xmlPath = Join-Path $directory 'brave-associations.xml'
$backupPath = Join-Path $directory 'browser-policy-backup.json'
$policyKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
$policyName = 'DefaultAssociationsConfiguration'
$taskName = 'Dotfiles-RestoreWindowsPreferences'

function Set-NeverSleep {
    foreach ($setting in @('monitor-timeout-ac', 'monitor-timeout-dc',
            'standby-timeout-ac', 'standby-timeout-dc',
            'hibernate-timeout-ac', 'hibernate-timeout-dc')) {
        & "$env:SystemRoot\System32\powercfg.exe" /change $setting 0
        if ($LASTEXITCODE -ne 0) { throw "powercfg failed for $setting ($LASTEXITCODE)." }
    }
}

if (!$PSCmdlet.ShouldProcess('Windows preferences', $Mode)) { return }

if ($Mode -eq 'Uninstall') {
    if (Test-Path -LiteralPath $backupPath) {
        $backup = Get-Content -LiteralPath $backupPath -Raw | ConvertFrom-Json
        $current = Get-ItemPropertyValue -LiteralPath $policyKey -Name $policyName -ErrorAction SilentlyContinue
        if ($current -eq $xmlPath) {
            if ($backup.Exists) {
                New-ItemProperty -Path $policyKey -Name $policyName -Value $backup.Value -PropertyType String -Force | Out-Null
            } else {
                Remove-ItemProperty -LiteralPath $policyKey -Name $policyName
            }
        } elseif ($null -ne $current) {
            Write-Warning 'Browser policy was changed elsewhere; leaving it intact.'
        }
    }
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) { $task | Unregister-ScheduledTask -Confirm:$false }
    Write-Host "Automatic restoration removed. Backup retained at $backupPath. Power timeouts remain unchanged."
    return
}

if ($Mode -eq 'Install') {
    # Read Brave's registered capabilities, including per-user installation IDs.
    $capabilities = $null
    foreach ($hive in @('HKCU:', 'HKLM:')) {
        $registered = Get-ItemProperty -LiteralPath "$hive\Software\RegisteredApplications" -ErrorAction SilentlyContinue
        if (!$registered) { continue }
        foreach ($entry in $registered.PSObject.Properties) {
            if ($entry.Name -notmatch '^Brave') { continue }
            $candidate = "$hive\$($entry.Value)"
            if (Test-Path -LiteralPath "$candidate\URLAssociations") {
                $capabilities = $candidate
                break
            }
        }
        if ($capabilities) { break }
    }
    if (!$capabilities) { throw 'Brave registration not found. Install and launch Brave for this Windows account first.' }

    $document = New-Object System.Xml.XmlDocument
    $root = $document.CreateElement('DefaultAssociations')
    $null = $document.AppendChild($root)
    foreach ($identifier in @('http', 'https', '.htm', '.html')) {
        $section = if ($identifier.StartsWith('.')) { 'FileAssociations' } else { 'URLAssociations' }
        $progId = Get-ItemPropertyValue -LiteralPath "$capabilities\$section" -Name $identifier
        if (!$progId) { throw "Brave has no registered handler for $identifier." }
        $association = $document.CreateElement('Association')
        $association.SetAttribute('Identifier', $identifier)
        $association.SetAttribute('ProgId', $progId)
        $association.SetAttribute('ApplicationName', 'Brave')
        $null = $root.AppendChild($association)
    }

    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    if (!(Test-Path -LiteralPath $backupPath)) {
        $previous = Get-ItemPropertyValue -LiteralPath $policyKey -Name $policyName -ErrorAction SilentlyContinue
        @{ Exists = ($null -ne $previous); Value = $previous } |
            ConvertTo-Json | Set-Content -LiteralPath $backupPath -Encoding UTF8
    }
    $document.Save($xmlPath)
    if ([IO.Path]::GetFullPath($PSCommandPath) -ne [IO.Path]::GetFullPath($installedScript)) {
        Copy-Item -LiteralPath $PSCommandPath -Destination $installedScript -Force
    }
    New-Item -Path $policyKey -Force | Out-Null
    New-ItemProperty -Path $policyKey -Name $policyName -Value $xmlPath -PropertyType String -Force | Out-Null

    # Run after each sign-in, with a delay for startup software that resets power settings.
    # The elevated task runs only this copy under ProgramData, never a WSL/repo path.
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument ('-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' + $installedScript + '" -Mode Apply')
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $identity
    $trigger.Delay = 'PT30S'
    $principal = New-ScheduledTaskPrincipal -UserId $identity -LogonType Interactive -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 2)
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
}

Set-NeverSleep
Write-Host 'Display, idle sleep and idle hibernation: Never (plugged in and battery).'
if ($Mode -eq 'Install') {
    Write-Host 'Installed sign-in task. Sign out and back in for the Brave browser policy to take effect.'
    Write-Host 'If Windows does not apply the browser policy, select Brave in Settings > Apps > Default apps.'
}
