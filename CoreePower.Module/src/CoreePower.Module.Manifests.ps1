
<#
.SYNOPSIS
    Reads PowerShell manifest files (.psd1) from a specified location and returns their content as an array of PSCustomObjects.

.DESCRIPTION
    This function scans a specified directory or file path for PowerShell manifest files (.psd1) and reads their content into PSCustomObjects.
    It can handle both a directory path and an individual file path as input. 
    The function leverages the Read-ManifestsFile helper function to do the actual file reading and parsing.

.PARAMETER ManifestLocation
    The full path to the location (directory or file) containing the PowerShell manifest files (.psd1) to read.
    This parameter is mandatory and cannot be null or empty.

.EXAMPLE
    Read-Manifests -ManifestLocation "C:\Path\To\Directory"
    This will read all .psd1 files in the specified directory and its subdirectories, parsing them into PSCustomObjects.

.EXAMPLE
    Read-Manifests -ManifestLocation "C:\Path\To\Manifest.psd1"
    This will read the specified .psd1 file and parse it into a PSCustomObject.
#>
function Read-Manifests {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ManifestLocation
    )

    if (Test-Path -Path "$ManifestLocation" -PathType Container)
    {
        $PowerShellModuleManifestsFiles = Get-ChildItem -Path "$ManifestLocation" -Recurse | Where-Object { $_.Extension -eq ".psd1" }
    } 
    elseif (Test-Path -Path "$ManifestLocation" -PathType Leaf)
    {
        $PowerShellModuleManifestsFiles = Get-Item "$ManifestLocation" | Where-Object { $_.Extension -eq ".psd1" }
    }
    else {
        return
    }

    $PowerShellModuleManifestsData = @()

    foreach($item in $PowerShellModuleManifestsFiles)
    {
        $PowerShellModuleManifestsData += Read-ManifestsFile -FullName "$($item.FullName)"
    }
  
    return $PowerShellModuleManifestsData
}

<#
.SYNOPSIS
    Reads a Manifest file and returns its content as a PSCustomObject.

.DESCRIPTION
    This function reads a manifest file located at a specified path and parses its content into a PSCustomObject.

.PARAMETER FullName
    The full path to the manifest file that needs to be read.

.EXAMPLE
    Read-ManifestsFile -FullName "C:\Path\To\Manifest.psd1"
#>
function Read-ManifestsFile {
    # Suppressing the warning for using an unapproved verb
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FullName
    )

    # Check if the file path exists
    if (-not(Test-Path -Path "$FullName" -PathType Leaf))
    {
        return
    }
    $itemFileInfo = Get-Item "$($FullName)"
    $itemFileContent = Get-Content -Path "$($FullName)" -Raw

    # Check for the opening and closing brackets to ensure validity of content
    $indexOpenBracket = $itemFileContent.IndexOf("@{")
    $indexCloseBracket = $itemFileContent.LastIndexOf("}")

    # Validate the indices for opening and closing brackets
    if (($indexOpenBracket -ne -1) -and ($indexCloseBracket -ne -1))
    {
        # Manipulate the string to form a PSCustomObject
        $PSCustomObjectString = $itemFileContent.Substring(0,  $indexOpenBracket ) + $itemFileContent.Substring($indexOpenBracket  + 2)
        $indexCloseBracket = $PSCustomObjectString.LastIndexOf("}")
        $PSCustomObjectString = $PSCustomObjectString.Substring(0,  $indexCloseBracket ) + $PSCustomObjectString.Substring($indexCloseBracket  + 1)
        
        # Add additional properties to the PSCustomObject string
        $PSCustomObjectString += "PSDFullName = '$FullName'"
        $PSCustomObjectString += "`n"
        $PSCustomObjectString += "PSDBaseName = '$($itemFileInfo.BaseName)'"
        $PSCustomObjectString += "`n"
        $PSCustomObjectString += "PSDDirectoryName = '$($itemFileInfo.DirectoryName)'"
    
        # Evaluate the string into a PSCustomObject
        $result = Invoke-Expression "[PSCustomObject]@{$PSCustomObjectString}"

        return $result
    } else {
        return
    }
}