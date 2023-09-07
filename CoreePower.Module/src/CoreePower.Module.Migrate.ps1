
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
