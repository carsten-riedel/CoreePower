

function Test-ReadPsdxxx {
    param()
    [bool]$retval = $false;
    Read-ManifestsFile -FullName "C:\temp"
    $retval = $true
    return $retval
}

function Test-Get-WorkspacePowerShellModuleManifestsDataxxx {
    param()
    [bool]$retval = $false;
    Read-Manifests -ManifestLocation "C:\Temp\CoreePower\CoreePower.Config\src\"
    Read-Manifests -ManifestLocation "C:\Temp\"
    $retval = $true
    return $retval
}

function Test-UpdateModule {
    param()
    [bool]$retval = $false;
    UpdateModule
    $retval = $true
    return $retval
}



