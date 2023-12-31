<#
    CoreePower.Module root module
#>

#Import-Module -Name "CoreePower.Lib" -DisableNameChecking

. "$PSScriptRoot\CoreePower.Module.IPrompt.ps1"
. "$PSScriptRoot\CoreePower.Module.ps1"
. "$PSScriptRoot\CoreePower.Module.Management.ps1"
. "$PSScriptRoot\CoreePower.Module.Manifests.ps1"
. "$PSScriptRoot\CoreePower.Module.UpdateModule.ps1"
. "$PSScriptRoot\CoreePower.Module.PublishModule.ps1"
. "$PSScriptRoot\CoreePower.Module.CreateModule.ps1"
. "$PSScriptRoot\CoreePower.Module.ListModule.ps1"
. "$PSScriptRoot\CoreePower.Module.Migrate.ps1"
. "$PSScriptRoot\CoreePower.Module.RemoveModules.ps1"
. "$PSScriptRoot\CoreePower.Module.GetModules.ps1"
. "$PSScriptRoot\CoreePower.Module.UpdateModules.ps1"

