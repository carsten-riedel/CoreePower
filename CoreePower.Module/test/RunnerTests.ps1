

function Test-ReadPsdxxx {
    param()
    [bool]$retval = $false;
    $x = Read-ManifestsFile -FullName "C:\temp"
    $retval = $true
    return $retval
}

function Test-Get-WorkspacePowerShellModuleManifestsDataxxx {
    param()
    [bool]$retval = $false;
    $x = Read-Manifests -ManifestLocation "C:\Temp\CoreePower\CoreePower.Config\src\"
    $y = Read-Manifests -ManifestLocation "C:\Temp\"
    $retval = $true
    return $retval
}



