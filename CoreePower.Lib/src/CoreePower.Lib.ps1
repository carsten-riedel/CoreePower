#https://learn.microsoft.com/en-us/nuget/consume-packages/configuring-nuget-behavior
#https://learn.microsoft.com/en-us/nuget/consume-packages/managing-the-global-packages-and-cache-folders

function Initialize-CorePowerLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cpcp")] 
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    Initialize-DevTools -Scope $Scope

}


function Get-CurrentModule {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("mocu")]
    param(
        $MyInvocationMyCommand = $null
    )

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
    return ,$moduleName , $moduleVersion
}
