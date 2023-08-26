param(
  [string]$Mode
)

Write-Host "debug.ps1 called in Mode: $Mode"

#You should dotsource all required files in you module
if ($Mode -eq "psm"){
    $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/microsoft/azure-pipelines-agent/releases" -AssetNameFilters @("pipelines-agent","win","x64",".zip")
    $x = 1
}

#You should dotsource all required files in you module, only exported function will be availible
if ($Mode -eq "psd"){
    
}

