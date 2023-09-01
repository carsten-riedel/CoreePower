param(
  [string]$Mode
)

$workspaceFolder = (Get-Location).Path

Write-Host "debug.ps1 called in Mode: $Mode"

if ($Mode -eq "remove")
{
  Remove-ManagementModules -ModuleNames @("CoreePower.Common","CoreePower.Lib","CoreePower.Config") -Scope CurrentUser
  $Mode = "psm"
}

#CreateModule3  -ModuleName "CoreePower.Foo" -Description "Library for module management" -Author "Carsten Riedel"
#. "$($parent.FullName)\CoreePower.Foo\test\RunnerImport.ps1"

#. "$workspaceFolder\CoreePower.Common\test\RunnerImport.ps1"
. "$workspaceFolder\CoreePower.Lib\test\RunnerImport.ps1"
#. "$workspaceFolder\CoreePower.Module\test\RunnerImport.ps1"
