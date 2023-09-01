<#
.SYNOPSIS
    Adds a custom enumeration type if the 'ModuleRecordState' type does not exist.

.DESCRIPTION
    The code block checks if the 'ModuleRecordState' type exists. If it does not exist, it adds a custom enumeration type named 'ModuleRecordState' with three values: 'Latest', 'Previous', and 'All'. This enumeration type is used in certain functions and scripts to specify the module version range of PowerShell modules.

.NOTES
    - This code block is used in PowerShell if there is no 'ModuleRecordState' type defined.
    - The 'ModuleRecordState' enumeration is used to indicate the desired range of module versions to be returned when searching for multiple versions of a module.
    - If the 'ModuleRecordState' type already exists, this code block has no effect.
#>

if (-not ([System.Management.Automation.PSTypeName]'ModuleRecordState').Type) {
    Add-Type @"
    public enum ModuleRecordState {
        Latest,
        Previous,
        All
    }
"@
}

<#
.SYNOPSIS
    Adds a custom enumeration type if the 'ModuleScope' type does not exist.

.DESCRIPTION
    The code block checks if the 'ModuleScope' type exists. If it does not exist, it adds a custom enumeration type named 'ModuleScope' with two values: 'CurrentUser' and 'LocalMachine'. This enumeration type is used in certain functions and scripts to specify the scope of PowerShell modules.

.NOTES
    - This code block is used in PowerShell if there is no 'ModuleScope' type defined.
    - The 'ModuleScope' enumeration is used to indicate whether a PowerShell module should be retrieved from the current user's scope or the local machine's scope.
    - If the 'ModuleScope' type already exists, this code block has no effect.
#>
if (-not ([System.Management.Automation.PSTypeName]'ModuleScope').Type) {
    Add-Type @"
    public enum ModuleScope {
        CurrentUser,
        LocalMachine,
        Process
    }
"@
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
function Remove-ManagementModules {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [string[]]$ModuleNames,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    
    $outdated = Get-ManagementModulesLocal -ModuleNames $ModuleNames -Scope $Scope -ExcludeSystemModules $true -ModulRecordState All
 
    foreach ($item in $outdated)
    {
        $DirVers = "$($item.BasePath)\$($item.Name)\$($item.Version)"
        Remove-Item -Recurse -Force -Path $DirVers
        Write-Host "Removed module:" $DirVers
    }
}

<#
.SYNOPSIS
    Retrieves local modules based on specified criteria.

.DESCRIPTION
    The Get-ModulesLocal function retrieves local modules based on the specified module names, scope, and record state.

.PARAMETER ModuleNames
    Specifies the names of the modules to retrieve. By default, all modules are included.

.PARAMETER Scope
    Specifies the scope from which to retrieve the modules. The available options are: LocalMachine, CurrentUser.
    The default value is LocalMachine.

.PARAMETER ExcludeSystemModules
    Determines whether system modules are excluded from the results. By default, system modules are excluded.

.PARAMETER ModuleRecordState
    Specifies the record state of the modules to retrieve. The available options are: Latest, Previous.
    The default value is Latest.

.OUTPUTS
    Returns the collection of local modules based on the specified criteria.

.EXAMPLE
    Get-ModulesLocal -ModuleNames ModuleA, ModuleB -Scope CurrentUser
    Retrieves the local modules with the names 'ModuleA' and 'ModuleB' from the CurrentUser scope.

.EXAMPLE
    Get-ModulesLocal -ModuleNames '*' -ExcludeSystemModules $false
    Retrieves all local modules, including system modules.
#>
function Get-ManagementModulesLocal {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("mol")]
    param(
        [string[]] $ModuleNames = @('*'),
        [ModuleScope]$Scope = [ModuleScope]::LocalMachine,
        [bool]$ExcludeSystemModules = $true,
        [ModuleRecordState]$ModulRecordState = [ModuleRecordState]::Latest
    )

    $ModuleInfo = Get-ManagementModulesInfoExtended -ModuleNames $ModuleNames -Scope $Scope -ExcludeSystemModules $ExcludeSystemModules
    $LocalModulesAll = $ModuleInfo | Sort-Object Name, Version -Descending

    if ($ModulRecordState -eq [ModuleRecordState]::Latest) {
        $LatestLocalModules = $LocalModulesAll | Group-Object Name | ForEach-Object { $_.Group | Select-Object -First 1  }
    }
    elseif ($ModulRecordState -eq [ModuleRecordState]::Previous){
        $LatestLocalModules = $LocalModulesAll | Group-Object Name | ForEach-Object { $_.Group | Select-Object -Skip 1  }
    } else {
        $LatestLocalModules = $LocalModulesAll | Group-Object Name | ForEach-Object { $_.Group }
    }

    return $LatestLocalModules
}

<#
.SYNOPSIS
    Retrieves information about installed PowerShell modules with extended details.

.DESCRIPTION
    The `Get-ModulesInfoExtended` cmdlet retrieves information about installed PowerShell modules, including their name, version, author, and description, as well as extended details about their installation location and scope.
    By default, it retrieves information about all modules installed on the local machine, including modules installed in both the `LocalMachine` and `CurrentUser` scopes.
    Note that when multiple versions of a module are installed on a system, the latest version takes precedence, regardless of whether it is installed in the `LocalMachine` or `CurrentUser` scope.
    Therefore, in this context, `LocalMachine` refers to modules installed in both `LocalMachine` and `CurrentUser` scopes.

.PARAMETER ModuleNames
    Specifies the names of the PowerShell modules to retrieve information for. You can use the wildcard character (*) to retrieve information about all installed modules. 

.PARAMETER Scope
    Specifies the scope of the PowerShell modules to retrieve information for. The available values are "LocalMachine" and "CurrentUser".

.PARAMETER ExcludeSystemModules
    Indicates whether to exclude modules that are installed in system folders from the results. If specified, modules that are installed in system folders (including both user-installed and system-installed modules) are excluded from the results.

.OUTPUTS
    The cmdlet returns an object that includes the following properties additional information for each installed module:
    - BasePath: the base path of the module's installation directory
    - IsMachine: a boolean value indicating whether the module is installed in a machine-wide folder
    - IsUser: a boolean value indicating whether the module is installed in a user-specific folder
    - IsSystem: a boolean value indicating whether the module is installed in a system folder (i.e., a folder within the Windows directory)

.EXAMPLE
    PS C:\> Get-ModulesInfoExtended

    This command retrieves information about all installed PowerShell modules on the local machine, including extended details about their installation location and scope.

.EXAMPLE
    PS C:\> Get-ModulesInfoExtended -ModuleNames MyModule

    This command retrieves information about the PowerShell module named "MyModule", including extended details about its installation location and scope.

.EXAMPLE
    PS C:\> Get-ModulesInfoExtended -Scope LocalMachine -ExcludeSystemModules $true

    This command retrieves information about all installed PowerShell modules, excluding modules that are installed in system folders from the results.
#>
function Get-ManagementModulesInfoExtended {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("moie")]
    param(
        [string[]] $ModuleNames = @('*'),
        [ModuleScope]$Scope = [ModuleScope]::LocalMachine,
        [bool]$ExcludeSystemModules = $false
    )

    $LocalModulesAll = Get-Module -Name $ModuleNames -ListAvailable  |  Select-Object *,
        @{ Name='BasePath' ; Expression={ $_.ModuleBase.TrimEnd($_.Version.ToString()).TrimEnd('\').TrimEnd($_.Name).TrimEnd('\')  } },
        @{ Name='IsMachine' ; Expression={ ($_.ModuleBase -Like "*$env:ProgramFiles*") -or ($_.ModuleBase -Like "*$env:ProgramW6432*")  } },
        @{ Name='IsUser' ; Expression={ ($_.ModuleBase -Like "*$env:userprofile*") } },
        @{ Name='IsSystem' ; Expression={ ($_.ModuleBase -Like "*$env:SystemRoot*")  } } 

    if ($Scope -eq [ModuleScope]::LocalMachine -and ($ExcludeSystemModules -eq $false))
    {
        return $LocalModulesAll
    }
    elseif ($Scope -eq [ModuleScope]::LocalMachine -and ($ExcludeSystemModules -eq $true)) {
        $LocalAndUser = $LocalModulesAll | Where-Object { $_.IsSystem -eq $false }
        return $LocalAndUser
    }
    elseif ($Scope -eq [ModuleScope]::CurrentUser) {
        $UserModules = $LocalModulesAll | Where-Object { $_.IsUser -eq $true }
        return $UserModules
    }
}