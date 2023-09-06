function Initialize-PowershellInitiated {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($null -ne $MyInvocation.MyCommand.Module)
    {
        $module = Get-Module -Name $MyInvocation.MyCommand.Module.Name
        $moduleName = $module.Name
        $moduleVersion = $module.Version
    }
    else {
        $moduleName = $MyInvocation.MyCommand.CommandType
        $moduleVersion = "None"
    }

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-DevTools in module version: $moduleVersion" -SuffixText "Start"
}

function Initialize-PowershellCompleted {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [bool]$RestartRequired,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($null -ne $MyInvocation.MyCommand.Module)
    {
        $module = Get-Module -Name $MyInvocation.MyCommand.Module.Name
        $moduleName = $module.Name
        $moduleVersion = $module.Version
    }
    else {
        $moduleName = $MyInvocation.MyCommand.CommandType
        $moduleVersion = "None"
    }

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-DevTools in module version: $moduleVersion" -SuffixText "Completed"

    if ($RestartRequired)
    {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "A restart of Powershell is required to implement the update." -SuffixText "Info"
    }
}

function Initialize-PowershellBase {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cppb")] 
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $moduleName , $moduleVersion = Get-CurrentModule 
    $updatesDone = $false

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetPackageProvider" -SuffixText "Initiated"
    Initialize-NugetPackageProvider -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetPackageProvider" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PowerShellGet" -SuffixText "Initiated"
    Initialize-PowerShellGet  -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PowerShellGet" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PackageManagement" -SuffixText "Initiated"
    Initialize-PackageManagement  -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PackageManagement" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetSourceRegistered" -SuffixText "Initiated"
    Initialize-NugetSourceRegistered
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetSourceRegistered" -SuffixText "Completed"

    return $updatesDone
}