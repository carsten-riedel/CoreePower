<#
    CoreePower.Lib root module
#>

# You can specify multiple .ps1 files here, but it's recommended to keep module functionality in a single file.
# Calling functions directly in .psm1 files requires enhanced system configuration, which is not standard practice.

Import-Module -Name "CoreePower.Common" -MinimumVersion "0.0.0.14" -DisableNameChecking

. "$PSScriptRoot\CoreePower.Lib.Initialize.Powershell.NugetPackageProvider.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.Powershell.PowerShellGet.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.Powershell.PackageManagement.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.Powershell.NugetSourceRegistered.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.Powershell.Base.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.7z.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Git.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Gh.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Wix.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Nuget.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Dotnet.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.VsCode.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Imagemagick.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.GitActionsRunner.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Pwsh.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Python.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.MsOpenjdk17.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.AzurePipelinesAgent.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Baget.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.ps1"
. "$PSScriptRoot\CoreePower.Lib.ps1"