

function Get-WorkspacePowerShellModuleManifestsData {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Workspace
    )

    $PowerShellModuleManifestsData = @()
    $PowerShellModuleManifestsFiles = Get-ChildItem -Path $Workspace -Recurse | Where-Object { $_.Extension -eq ".psd1" }

    foreach($item in $PowerShellModuleManifestsFiles)
    {
        $PowerShellModuleManifestsData += ReadPsdx -FullName "$($item.FullName)"
    }
  
    return $PowerShellModuleManifestsData
}

function ReadPsdx {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FullName
    )
    $filenfo = Get-Item "$($FullName)"
    $fileContent = Get-Content -Path "$($FullName)" -Raw
    #Remove the first @{ from $fileContent
    $index = $fileContent.IndexOf("@{")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }
    #Remove the last } from $fileContent
    $index = $fileContent.LastIndexOf("}")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }

    $fileContent += "PSDBaseName = '$($filenfo.BaseName)'"
    $fileContent += "`n"
    $fileContent += "PSDFullName = '$($FullName)'"
    $fileContent += "`n"
    $fileContent += "PSDDirectoryName = '$($filenfo.DirectoryName)'"

    $result = Invoke-Expression "[PSCustomObject]@{$fileContent}"

    return $result
}

function Resolve-CoreePowerModule {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Workspace,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$MinVersion
    )

    $result = Get-WorkspacePowerShellModuleManifestsData -Workspace "$Workspace"

    $mdo = $result | Where-Object { $_.PSDBaseName -eq "CoreePower.Module" } | Select-Object -First 1
    if ($mdo)
    {
        if (Get-Module -Name "$($mdo.PSDBaseName)")
        {
            Uninstall-Module -Name "$($mdo.PSDBaseName)" -AllVersions -Force -Verbose
        }
        Import-Module "$($mdo.PSDFullName)" -Force
        #Write-Output "Import-Module '$($mdo.PSDFullName)' -Force"
    }
    else {
        $cmdaviable = Get-Command -FullyQualifiedModule @(@{ModuleName = "CoreePower.Module"; ModuleVersion = $MinVersion; })
        if (-not($cmdaviable))
        {
            Install-Module -Name "CoreePower.Module" -Scope CurrentUser -MinimumVersion $MinVersion -AllowClobber -Force
            Import-Module "CoreePower.Module" -MinimumVersion $MinVersion -Force
        }
    }
}






