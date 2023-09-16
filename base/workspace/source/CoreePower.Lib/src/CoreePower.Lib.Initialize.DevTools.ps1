function Initialize-DevTools {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cpdev")] 
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $RestartRequired = $false

    $global:CoreeDevToolsRoot = "$($env:localappdata)\CoreeDevTools"

    Initialize-PowershellInitiated

    $UpdatesDoneDevToolsBase = Initialize-PowershellBase

    $UpdatesDoneDevTools7z = Initialize-DevTools7z
    $UpdatesDoneDevToolsGit = Initialize-DevToolsGit
    $UpdatesDoneDevToolsGh = Initialize-DevToolsGh
    $UpdatesDoneDevToolsNuget = Initialize-DevToolsNuget
    $UpdatesDoneDevToolsWix = Initialize-DevToolsWix
    $UpdatesDoneDevToolsImagemagick = Initialize-DevToolsImagemagick

    $UpdatesDoneDevToolsDotnet = Initialize-DevToolsDotnet
    $UpdatesDoneDevToolsVsCode = Initialize-DevToolsVsCode

    $UpdatesDoneDevToolsGitActionsRunner = Initialize-DevToolsGitActionsRunner
    $UpdatesDoneDevToolPwsh = Initialize-DevToolPwsh
    $UpdatesDoneDevToolPython = Initialize-DevToolPython
    $UpdatesDoneDevToolMsOpenjdk17 = Initialize-DevToolsMsOpenjdk17
    $UpdatesDoneDevToolAzurePipelinesAgent = Initialize-DevToolsAzurePipelinesAgent
    $UpdatesDoneDevToolsBaget = Initialize-DevToolsBaget

    $RestartRequired = $RestartRequired -or $UpdatesDoneDevToolsBase
    $RestartRequired = $RestartRequired -or $UpdatesDoneDevToolsCoreeModules
    $RestartRequired = $RestartRequired -or $UpdatesDoneDevToolsCoreeLibSelf

    Initialize-PowershellCompleted -RestartRequired $RestartRequired

}
