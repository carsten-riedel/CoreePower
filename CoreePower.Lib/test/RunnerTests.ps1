

function Test-Initialize-DevTools7z {
    param()
    [bool]$retval = $false;
    try {
        CoreePower.Lib\Initialize-DevTools7z
    }
    catch {
        wn $_
        wn $_.ScriptStackTrace
        wn $_.Exception
        return $false
    }
    
    $retval = $true
    return $retval
}

function Test-Initialize-PowerShellGet {
    param()
    [bool]$retval = $false;
    try {
        CoreePower.Lib\Initialize-PowerShellGet
    }
    catch {
        wn $_
        wn $_.ScriptStackTrace
        wn $_.Exception
        return $false
    }
    
    $retval = $true
    return $retval
}

function Test-Initialize-PackageManagement {
    param()
    [bool]$retval = $false;
    try {
        CoreePower.Lib\Initialize-PackageManagement
    }
    catch {
        wn $_
        wn $_.ScriptStackTrace
        wn $_.Exception
        return $false
    }
    
    $retval = $true
    return $retval
}

