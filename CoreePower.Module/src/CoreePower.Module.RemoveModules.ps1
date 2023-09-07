<#
.SYNOPSIS
    Removes previous versions of specified modules.

.DESCRIPTION
    The Remove-ModulesPrevious function removes previous versions of modules from the specified scope.

.PARAMETER ModuleNames
    Specifies the names of the modules to remove. This parameter is mandatory.

.PARAMETER Scope
    Specifies the scope from which to remove the modules. The available options are: CurrentUser, LocalMachine.
    The default value is CurrentUser.
#>
function Remove-ModulesPrevious {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("morp")]
    param(
        [string[]]$ModuleNames = @('*'),
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    $outdated = Get-ModulesLocal -ModuleNames $ModuleNames -Scope $Scope -ExcludeSystemModules $true -ModulRecordState Previous
 
    foreach ($item in $outdated)
    {
        $DirVers = "$($item.BasePath)\$($item.Name)\$($item.Version)"
        Remove-Item -Recurse -Force -Path $DirVers
        Write-Host "Removed module:" $DirVers
    }
}

<#
.SYNOPSIS
    Removes specified PowerShell modules from the current user's module directory.

.DESCRIPTION
    The `Remove-Modules` function removes specified PowerShell modules from the module directory of the current user. It allows for the removal of modules that are no longer needed or outdated.

.PARAMETER ModuleNames
    Specifies the names of the PowerShell modules to be removed. Multiple module names can be provided as an array.

.PARAMETER Scope
    Specifies the scope of the module removal operation. The available values are "LocalMachine" and "CurrentUser". The default value is "CurrentUser".

.NOTES
    - The function requires appropriate permissions to remove modules from the module directory.
    - Removing modules will permanently delete their associated files and directories.
    - The function does not remove modules installed in system folders.
    - It is recommended to use caution when removing modules, as it may affect the functionality of dependent scripts or applications.

.EXAMPLE
    PS C:\> Remove-Modules -ModuleNames "Module1", "Module2"

    This command removes the PowerShell modules named "Module1" and "Module2" from the current user's module directory.

.EXAMPLE
    PS C:\> Remove-Modules -ModuleNames "OutdatedModule" -Scope CurrentUser

    This command removes the PowerShell module named "OutdatedModule" from the module directory of the current user.

.EXAMPLE
    PS C:\> Remove-Modules -ModuleNames "Module3" -Scope LocalMachine

    This command removes the PowerShell module named "Module3" from the module directory of the local machine.

.NOTES
    This function internally uses the `Get-ModulesLocal` function to retrieve module information and the `Remove-Item` cmdlet to delete module files and directories.
#>
function Remove-Modules {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("morm")]
    param(
        [string[]]$ModuleNames,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

  
    $outdated = Get-ModulesLocal -ModuleNames $ModuleNames -Scope $Scope -ExcludeSystemModules $true -ModulRecordState All
 
    foreach ($item in $outdated)
    {
        $DirVers = "$($item.BasePath)\$($item.Name)\$($item.Version)"
        Remove-Item -Recurse -Force -Path $DirVers
        Write-Host "Removed module:" $DirVers
    }
}
