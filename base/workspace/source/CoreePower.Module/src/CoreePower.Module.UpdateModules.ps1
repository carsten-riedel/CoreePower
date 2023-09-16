<#
.SYNOPSIS
    Updates specified PowerShell modules to their latest versions.

.DESCRIPTION
    The `Update-ModulesLatest` function updates specified PowerShell modules to their latest versions. It retrieves the available updates for the specified modules and installs them, ensuring that the modules are up to date.

.PARAMETER ModuleNames
    Specifies the names of the PowerShell modules to be updated. Multiple module names can be provided as an array. By default, all installed modules are considered for updating.

.PARAMETER Scope
    Specifies the scope of the module update operation. The available values are "LocalMachine" and "CurrentUser". The default value is "CurrentUser".

.PARAMETER SuppressProgressPreference
    Indicates whether to suppress progress preference during the update process. By default, progress preference is not suppressed.

.NOTES
    - The function requires appropriate permissions to update modules in the module directory.
    - The function internally uses the `Get-ModulesUpdatable` function to retrieve information about available module updates.
    - The function uses the `Install-Module` cmdlet to install the updates.
    - Use caution when updating modules, as it may affect the functionality of dependent scripts or applications.

.EXAMPLE
    PS C:\> Update-ModulesLatest

    This command updates all installed PowerShell modules to their latest versions in the current user's module directory.

.EXAMPLE
    PS C:\> Update-ModulesLatest -ModuleNames "Module1", "Module2" -Scope LocalMachine

    This command updates the PowerShell modules named "Module1" and "Module2" to their latest versions in the module directory of the local machine.

.EXAMPLE
    PS C:\> Update-ModulesLatest -ModuleNames "*" -SuppressProgressPreference $true

    This command updates all installed PowerShell modules to their latest versions in the current user's module directory, suppressing progress preference during the update process.

.NOTES
    - If updates are applied successfully, the function returns `$true`. Otherwise, it returns `$false`.
    - It is recommended to regularly update modules to benefit from bug fixes and new features.
#>
function Update-ModulesLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("moul")]
    param(
        [string[]] $ModuleNames = @('*'),
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser,
        [bool]$SuppressProgressPreference = $false
    )

    $UpdatableModules = Get-ModulesUpdatable -ModuleNames $ModuleNames
    $UpdatesApplied = $false

    foreach($module in $UpdatableModules)
    {
        #Write-Output "Installing module: $($module.Name) $($module.Version)" 

        if ($SuppressProgressPreference)
        {
            $originalProgressPreference = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
        }
        Install-Module -Name $module.Name -RequiredVersion $module.Version -Scope $Scope -Repository $module.Repository -Force -AllowClobber -SkipPublisherCheck | Out-Null
        if ($SuppressProgressPreference)
        {
        
            $global:ProgressPreference = $originalProgressPreference
        }
        $UpdatesApplied = $true
    }
    if ($UpdatesApplied)
    {
        return $true
    } else {
        return $false
    }
}
