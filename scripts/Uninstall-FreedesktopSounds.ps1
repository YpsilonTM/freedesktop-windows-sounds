#Requires -Version 5.1
<#
.SYNOPSIS
  Removes the Freedesktop Windows sound scheme and installed files.
#>
[CmdletBinding()]
param(
    [string]$FallbackScheme = '.Default'
)

$ErrorActionPreference = 'Stop'

$SchemeName = 'Freedesktop'
$InstallRoot = Join-Path $env:LOCALAPPDATA 'FreedesktopSoundTheme'

$current = (Get-ItemProperty -Path 'HKCU:\AppEvents\Schemes' -Name '(default)').'(default)'
if ($current -eq $SchemeName) {
    Set-ItemProperty -Path 'HKCU:\AppEvents\Schemes' -Name '(default)' -Value $FallbackScheme

    Get-ChildItem 'HKCU:\AppEvents\Schemes\Apps' -ErrorAction SilentlyContinue | ForEach-Object {
        Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
            $fallbackKey = Join-Path $_.PSPath $FallbackScheme
            $currentKey = Join-Path $_.PSPath '.Current'
            if (Test-Path -LiteralPath $fallbackKey) {
                $value = (Get-ItemProperty -Path $fallbackKey -Name '(default)' -ErrorAction SilentlyContinue).'(default)'
                if ($null -ne $value) {
                    New-Item -Path $currentKey -Force | Out-Null
                    Set-ItemProperty -Path $currentKey -Name '(default)' -Value $value
                }
            }
        }
    }
}

Get-ChildItem 'HKCU:\AppEvents\Schemes\Apps' -ErrorAction SilentlyContinue | ForEach-Object {
    Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
        $schemeKey = Join-Path $_.PSPath $SchemeName
        if (Test-Path -LiteralPath $schemeKey) {
            Remove-Item -LiteralPath $schemeKey -Recurse -Force
        }
    }
}

$namesKey = 'HKCU:\AppEvents\Schemes\Names\{0}' -f $SchemeName
if (Test-Path -LiteralPath $namesKey) {
    Remove-Item -LiteralPath $namesKey -Recurse -Force
}

if (Test-Path -LiteralPath $InstallRoot) {
    Remove-Item -LiteralPath $InstallRoot -Recurse -Force
}

Write-Host "Removed Freedesktop sound scheme."
Write-Host "Active scheme set to: $FallbackScheme"
