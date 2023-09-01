Write-Host "launch.ps1 called."

$workspaceFolder = (Get-Location).Path

. "$workspaceFolder\.vscode\required.ps1"

Write-Host "launch.ps1 Ensure CoreePower.Module for further testing."
Resolve-CoreePowerModule -Workspace "$workspaceFolder" -MinVersion "0.0.0.66"

Write-Host "launch.ps1 Removing modules in conjunction to the test."
Remove-ManagementModules -ModuleNames @("CoreePower.Common","CoreePower.Lib","CoreePower.Config") -Scope CurrentUser

Write-Host "launch.ps1 Importing the test script."
. "$workspaceFolder\CoreePower.Lib\test\RunnerImport.ps1"

#CreateModule3  -ModuleName "CoreePower.Foo" -Description "Library for module management" -Author "Carsten Riedel"
#. "$($parent.FullName)\CoreePower.Foo\test\RunnerImport.ps1"

#. "$workspaceFolder\CoreePower.Common\test\RunnerImport.ps1"

#. "$workspaceFolder\CoreePower.Module\test\RunnerImport.ps1"
