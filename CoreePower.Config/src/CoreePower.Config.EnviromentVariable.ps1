
<#
.SYNOPSIS
Adds a new directory path to the system's environment variable PATH.

.PARAMETER Path
Specifies the new directory path to add.

.PARAMETER Scope
Specifies the scope where the new path will be added. This can be one of the following values: "CurrentUser" or "LocalMachine". The default value is "CurrentUser".

.NOTES
This function has an alias "addenvpath" for ease of use.

.EXAMPLE
The following example adds the directory "C:\NewDirectory" to the PATH environment variable for the current user:
AddToPathEnvironmentVariable -Path "C:\NewDirectory"

#>
function AddPathEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("addenvpath")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    
    if ($Scope -eq [Scope]::CurrentUser) {
        $USERPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::User)
        $NEW = "$USERPATHS;$Path"
        [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        $MACHINEPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Machine)
        $NEW = "$MACHINEPATHS;$Path"
        [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::Machine)
    }

    
}

<#
.SYNOPSIS
Groups and sorts the directories in the system's environment variable PATH for a specified scope.

.PARAMETER Scope
Specifies the scope to group and sort directories. This can be one of the following values: "CurrentUser" or "LocalMachine". The default value is "CurrentUser".

.NOTES
This function has an alias "groupsortenvpath" for ease of use.

.EXAMPLE
The following example groups and sorts the directories in the PATH environment variable for the local machine:
GroupAndSortPathEnvironmentVariable -Scope LocalMachine

#>
function GroupAndSortPathEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("groupsortenvpath")]
    param(
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [Scope]::CurrentUser) {
        $USERPATHSARRAY = @()
        $USERPATHSARRAY = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::User) -split ';'
        $USERPATHSARRAY = $USERPATHSARRAY | Group-Object | Select-object -Property Name | Sort-Object -Property Name
        $USERPATHSARRAYSTRING = $USERPATHSARRAY.Name  -join ';'
        [System.Environment]::SetEnvironmentVariable("PATH",$USERPATHSARRAYSTRING,[System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        $MachinePATHSARRAY = @()
        $MachinePATHSARRAY = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Machine) -split ';'
        $MachinePATHSARRAY = $MachinePATHSARRAY | Group-Object | Select-object -Property Name | Sort-Object -Property Name
        $MachinePATHSARRAYSTRING = $MachinePATHSARRAY.Name  -join ';'
        [System.Environment]::SetEnvironmentVariable("PATH",$MachinePATHSARRAYSTRING,[System.EnvironmentVariableTarget]::Machine)
    }
}

<#
.SYNOPSIS
Removes a directory path from the system's environment variable PATH for a specified scope.

.PARAMETER Path
Specifies the directory path to remove from the PATH environment variable.

.PARAMETER Scope
Specifies the scope where the path will be removed. This can be one of the following values: "CurrentUser" or "LocalMachine". The default value is "CurrentUser".

.NOTES
This function has an alias "delenvpath" for ease of use.

.EXAMPLE
The following example removes the directory "C:\OldDirectory" from the PATH environment variable for the current user:
DeletePathEnvironmentVariable -Path "C:\OldDirectory"

#>
function DeletePathEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("delenvpath")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Scope]$Scope = [Scope]::CurrentUser
    )
    
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [Scope]::CurrentUser) {
        $UserPathArrayNew = @()
        $UserPathArray = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::User) -split ';'
        foreach ($item in $UserPathArray)
        {
            if ($Path -notlike $item)
            {
                $UserPathArrayNew += $item
            }
        }
        $UserPathArrayNewString = $UserPathArrayNew  -join ';'
        [System.Environment]::SetEnvironmentVariable("PATH",$UserPathArrayNewString,[System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        $MachinePathArrayNew = @()
        $MachinePathArray = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Machine) -split ';'
        foreach ($item in $MachinePathArray)
        {
            if ($Path -notlike $item)
            {
                $MachinePathArrayNew += $item
            }
        }
        $MachinePathArrayNewString = $MachinePathArrayNew  -join ';'
        [System.Environment]::SetEnvironmentVariable("PATH",$MachinePathArrayNewString,[System.EnvironmentVariableTarget]::Machine)
    }
}

<#
.SYNOPSIS
Adds a new environment variable to the current user's environment or the local machine's environment.

.DESCRIPTION
Adds a new environment variable with the specified name and value to either the current user's environment or the local machine's environment. Uses the SetEnvironmentVariable method of the System.Environment class. If the scope is not specified, the function adds the variable to the current user's environment.

.PARAMETER Name
The name of the environment variable to add.

.PARAMETER Value
The value of the environment variable to add.

.PARAMETER Scope
The scope of the environment variable. The value can be either CurrentUser or LocalMachine. Default is CurrentUser.

.EXAMPLE
AddEnvironmentVariable -Name "MY_VARIABLE" -Value "my_value"
Adds a new environment variable named MY_VARIABLE with the value my_value to the current user's environment.

.EXAMPLE
AddEnvironmentVariable -Name "MY_VARIABLE" -Value "my_value" -Scope LocalMachine
Adds a new environment variable named MY_VARIABLE with the value my_value to the local machine's environment.

.NOTES
Requires administrative privileges to modify the local machine's environment variables. If the current process does not have the required permissions, the function will not execute.

#>
function AddEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("addenv")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [Scope]::CurrentUser) {
        [System.Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        [System.Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::Machine)
    }
}

<#
.SYNOPSIS
Deletes an environment variable from the current user's environment or the local machine's environment.

.DESCRIPTION
Deletes the environment variable with the specified name from either the current user's environment or the local machine's environment. Uses the SetEnvironmentVariable method of the System.Environment class with a null value to delete the variable. If the scope is not specified, the function deletes the variable from the current user's environment.

.PARAMETER Name
The name of the environment variable to delete.

.PARAMETER Scope
The scope of the environment variable. The value can be either CurrentUser or LocalMachine. Default is CurrentUser.

.EXAMPLE
DeleteEnvironmentVariable -Name "MY_VARIABLE"
Deletes the environment variable named MY_VARIABLE from the current user's environment.

.EXAMPLE
DeleteEnvironmentVariable -Name "MY_VARIABLE" -Scope LocalMachine
Deletes the environment variable named MY_VARIABLE from the local machine's environment.

.NOTES
Requires administrative privileges to delete environment variables from the local machine's environment. If the current process does not have the required permissions, the function will not execute.

#>
function DeleteEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("delenv")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [Scope]::CurrentUser) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::Machine)
    }
}

