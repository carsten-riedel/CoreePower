param(
  [string]$Mode
)

$workspaceFolder = (Get-Location).Path

#Import-Module "$workspaceFolder\CoreePower\CoreePower.Lib\src\CoreePower.Lib.$($Mode)1" -Force -Verbose
Import-Module "$workspaceFolder\CoreePower.Module\src\CoreePower.Module.$($Mode)1" -Force -Verbose

. "${PSScriptRoot}\debug.ps1" -Mode $Mode
