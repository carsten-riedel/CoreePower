<#
    CoreePower.Common root module
#>

# Add other depended modules here, you need to add them in the psd1 file as
# RequiredModules = @(@{ModuleName = 'Other.Module'; ModuleVersion = '0.0.0.30'; })
# The ModuleVersion is the minimum required version

#Import-Module -Name "Other.Module" -MinimumVersion "0.0.0.1"

. "$PSScriptRoot\CoreePower.Common.CustomConsole.ps1"
. "$PSScriptRoot\CoreePower.Common.Enum.ps1"
. "$PSScriptRoot\CoreePower.Common.Array.ps1"
. "$PSScriptRoot\CoreePower.Common.Scope.ps1"
. "$PSScriptRoot\CoreePower.Common.Modules.ps1"
. "$PSScriptRoot\CoreePower.Common.Environment.ps1"

