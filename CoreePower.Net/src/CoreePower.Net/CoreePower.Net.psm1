function Test-FileExistence {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$SearchDirs,

        [Parameter(Mandatory=$true)]
        [string]$FileName
    )

    foreach ($dir in $SearchDirs) {
        $filePath = Join-Path $dir $FileName
        if (Test-Path $filePath) {
            Write-Host "File found: $filePath"
            return $filePath
        }
    }

    Write-Host "File not found."
    return $null
}

$loc = Test-FileExistence -SearchDirs @("$PSScriptRoot","$PSScriptRoot/net6") -FileName "CoreePower.Net.dll"

Import-Module -Name "$loc" -Force



