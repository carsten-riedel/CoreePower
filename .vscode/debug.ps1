param(
  [string]$Mode
)

Write-Host "debug.ps1 called in Mode: $Mode"
$parent = (Get-Item $MyInvocation.PSScriptRoot).Parent

#CreateModule3  -ModuleName "CoreePower.Foo" -Description "Library for module management" -Author "Carsten Riedel"
#. "$($parent.FullName)\CoreePower.Foo\test\RunnerImport.ps1"

. "$($parent.FullName)\CoreePower.Common\test\RunnerImport.ps1"
