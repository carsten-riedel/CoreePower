

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

function Test-Initialize-DevToolsMsOpenjdk17 {
    param()
    [bool]$retval = $false;
    try {
        CoreePower.Lib\Initialize-DevToolsMsOpenjdk17
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

function Test-Initialize-DevToolsVsCode {
    param()
    [bool]$retval = $false;
    try {
        CoreePower.Lib\Initialize-DevToolsVsCode
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

