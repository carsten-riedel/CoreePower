Write-Host "launch.ps1 called."

$workspaceFolder = (Get-Location).Path

. "$workspaceFolder\.vscode\required.ps1"

Resolve-CoreePowerModule -Workspace "$workspaceFolder" -MinVersion "0.0.0.66"

Remove-ManagementModules -ModuleNames @("CoreePower.Common","CoreePower.Lib","CoreePower.Config") -Scope CurrentUser



#CreateModule3  -ModuleName "CoreePower.Foo" -Description "Library for module management" -Author "Carsten Riedel"
#. "$($parent.FullName)\CoreePower.Foo\test\RunnerImport.ps1"

#. "$workspaceFolder\CoreePower.Common\test\RunnerImport.ps1"
. "$workspaceFolder\CoreePower.Lib\test\RunnerImport.ps1"
#. "$workspaceFolder\CoreePower.Module\test\RunnerImport.ps1"
