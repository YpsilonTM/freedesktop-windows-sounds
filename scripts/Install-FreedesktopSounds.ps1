#Requires -Version 5.1
<#
.SYNOPSIS
  Installs the Freedesktop sound theme as a Windows sound scheme.
.DESCRIPTION
  Copies WAV files to %LOCALAPPDATA%\FreedesktopSoundTheme and registers /
  activates a HKCU sound scheme named "Freedesktop".
#>
[CmdletBinding()]
param(
    [switch]$NoActivate
)

$ErrorActionPreference = 'Stop'

$SchemeName = 'Freedesktop'
$SchemeDisplayName = 'Freedesktop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$SourceSounds = Join-Path $RepoRoot 'sounds'
$InstallRoot = Join-Path $env:LOCALAPPDATA 'FreedesktopSoundTheme'
$InstallSounds = Join-Path $InstallRoot 'sounds'

if (-not (Test-Path -LiteralPath $SourceSounds)) {
    throw "Sounds folder not found: $SourceSounds"
}

New-Item -ItemType Directory -Path $InstallSounds -Force | Out-Null
Copy-Item -Path (Join-Path $SourceSounds '*') -Destination $InstallSounds -Force

function SoundPath([string]$FileName) {
    Join-Path $InstallSounds $FileName
}

# appKey is relative to HKCU:\AppEvents\Schemes\Apps
$Mapping = @(
    @{ App = '.Default'; Event = '.Default';                 File = 'bell.wav' }
    @{ App = '.Default'; Event = 'SystemAsterisk';           File = 'dialog-information.wav' }
    @{ App = '.Default'; Event = 'SystemExclamation';        File = 'dialog-warning.wav' }
    @{ App = '.Default'; Event = 'SystemHand';               File = 'dialog-error.wav' }
    @{ App = '.Default'; Event = 'SystemQuestion';           File = 'window-question.wav' }
    @{ App = '.Default'; Event = 'SystemNotification';       File = 'message.wav' }
    @{ App = '.Default'; Event = 'Notification.Default';     File = 'message.wav' }
    @{ App = '.Default'; Event = 'Notification.IM';          File = 'message-new-instant.wav' }
    @{ App = '.Default'; Event = 'Notification.Mail';        File = 'message-new-instant.wav' }
    @{ App = '.Default'; Event = 'Notification.Reminder';    File = 'alarm-clock-elapsed.wav' }
    @{ App = '.Default'; Event = 'Notification.SMS';         File = 'message.wav' }
    @{ App = '.Default'; Event = 'MailBeep';                 File = 'message-new-instant.wav' }
    @{ App = '.Default'; Event = 'MessageNudge';             File = 'message.wav' }
    @{ App = '.Default'; Event = 'DeviceConnect';            File = 'device-added.wav' }
    @{ App = '.Default'; Event = 'DeviceDisconnect';         File = 'device-removed.wav' }
    @{ App = '.Default'; Event = 'DeviceFail';               File = 'suspend-error.wav' }
    @{ App = '.Default'; Event = 'ProximityConnection';      File = 'device-added.wav' }
    @{ App = '.Default'; Event = 'WindowsLogon';             File = 'service-login.wav' }
    @{ App = '.Default'; Event = 'WindowsLogoff';            File = 'service-logout.wav' }
    @{ App = '.Default'; Event = 'WindowsUnlock';            File = 'service-login.wav' }
    @{ App = '.Default'; Event = 'SystemExit';               File = 'service-logout.wav' }
    @{ App = '.Default'; Event = 'PrintComplete';            File = 'complete.wav' }
    @{ App = '.Default'; Event = 'CriticalBatteryAlarm';     File = 'alarm-clock-elapsed.wav' }
    @{ App = '.Default'; Event = 'LowBatteryAlarm';          File = 'alarm-clock-elapsed.wav' }
    @{ App = '.Default'; Event = 'Notification.Looping.Alarm'; File = 'alarm-clock-elapsed.wav' }
    @{ App = '.Default'; Event = 'Notification.Looping.Call';  File = 'phone-incoming-call.wav' }
    @{ App = 'Explorer';  Event = 'EmptyRecycleBin';         File = 'trash-empty.wav' }
)

$NamesKey = 'HKCU:\AppEvents\Schemes\Names\{0}' -f $SchemeName
New-Item -Path $NamesKey -Force | Out-Null
Set-ItemProperty -Path $NamesKey -Name '(default)' -Value $SchemeDisplayName

foreach ($entry in $Mapping) {
    $wav = SoundPath $entry.File
    if (-not (Test-Path -LiteralPath $wav)) {
        Write-Warning "Missing sound file: $($entry.File) — skipping $($entry.Event)"
        continue
    }

    $eventKey = 'HKCU:\AppEvents\Schemes\Apps\{0}\{1}' -f $entry.App, $entry.Event
    if (-not (Test-Path -LiteralPath $eventKey)) {
        New-Item -Path $eventKey -Force | Out-Null
    }

    $schemeKey = Join-Path $eventKey $SchemeName
    New-Item -Path $schemeKey -Force | Out-Null
    Set-ItemProperty -Path $schemeKey -Name '(default)' -Value $wav

    if (-not $NoActivate) {
        $currentKey = Join-Path $eventKey '.Current'
        New-Item -Path $currentKey -Force | Out-Null
        Set-ItemProperty -Path $currentKey -Name '(default)' -Value $wav
    }
}

if (-not $NoActivate) {
    Set-ItemProperty -Path 'HKCU:\AppEvents\Schemes' -Name '(default)' -Value $SchemeName
}

Write-Host "Installed Freedesktop sounds to: $InstallSounds"
if ($NoActivate) {
    Write-Host "Scheme registered as '$SchemeDisplayName' (not activated). Pick it in Sound settings."
} else {
    Write-Host "Activated sound scheme: $SchemeDisplayName"
    Write-Host "Tip: open Settings > System > Sound > More sound settings to preview events."
}
