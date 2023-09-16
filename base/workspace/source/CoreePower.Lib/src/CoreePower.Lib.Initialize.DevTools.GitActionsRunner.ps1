
function Initialize-DevToolsGitActionsRunner {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $moduleName , $moduleVersion = Get-CurrentModule -MyInvocationMyCommand $MyInvocation.MyCommand
    $updatesDone = $false

    $contentText = "github (Actions Runner)"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Check Dir"

    $targetdir = "$($global:CoreeDevToolsRoot)\actions-runner"

    if (-not(Test-Path -Path "$targetdir" -PathType Container)) {
        New-Item -ItemType Directory -Path "$targetdir" -Force | Out-Null
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Directory create"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download"
        $file = Get-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/actions/runner/releases" -AssetNameFilters @("win","x64",".zip") -BlackList @("noruntime","noexternals")
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Extracting"
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $targetdir
        $global:ProgressPreference = $originalProgressPreference
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Extracting Completed"
        Remove-TempDirectory -TempDirectory $file
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download removed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Adding envar"
        #Conflicts with with azure agent pipeline runner.
        #AddPathEnviromentVariable -Path "$targetdir" -Scope CurrentUser
        #Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Adding envar Completed"
        #Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Completed"

    return $updatesDone
}
