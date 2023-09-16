

function Test-Write-Notice {
    param()
    [bool]$retval = $false;
    wn "foo"
    $retval = $true
    return $retval
}

function Test-Write-FormatedText {
    param()
    [bool]$retval = $false;
    Write-FormatedText "foo"
    $retval = $true
    return $retval
}

function Test-Invoke-Prompt {
    param()
    [bool]$retval = $false;
    CoreePower.Common\Invoke-Prompt
    $retval = $true
    return $retval
}

function Test-Confirm-AdminRightsEnabled {
    param()
    [bool]$retval = $false;
    Confirm-AdminRightsEnabled
    $retval = $true
    return $retval
}

function Test-CanExecuteInDesiredScope {
    param()
    [bool]$retval = $false;
    CanExecuteInDesiredScope
    $retval = $true
    return $retval
}

function Test-CouldRunAsAdministrator {
    param()
    [bool]$retval = $false;
    CouldRunAsAdministrator
    $retval = $true
    return $retval
}

# 'Remove-ModulesPrevious', 'Remove-Modules', 'Update-ModulesLatest', 'Get-CurrentModule'

function Test-Get-ModulesInfoExtended {
    param()
    [bool]$retval = $false;
    
    try {
        $result = CoreePower.Common\Get-ModulesInfoExtended -Scope LocalMachine -ExcludeSystemModules $true
        foreach ($item in $result)
        {
            Write-Host "$($item.Name) $($item.Version)"
        }
    }
    catch {
        return $false
    }
    $retval = $true
    return $retval
}

function Test-Get-ModulesLocal {
    param()
    [bool]$retval = $false;
    [bool]$retval = $false;
    try {
        $result = CoreePower.Common\Get-ModulesLocal -ModuleNames '*' -ExcludeSystemModules $false
        foreach ($item in $result)
        {
            Write-Host "$($item.Name) $($item.Version)"
        }
    }
    catch {
        return $false
    }
    
    $retval = $true
    return $retval
}

function Test-Get-ModulesUpdatable {
    param()
    [bool]$retval = $false;
    try {
        $result = CoreePower.Common\Get-ModulesUpdatable -ModuleNames @("CoreePower.Lib", "CoreePower.Common","CoreePower.Config","CoreePower.Module")
        foreach ($item in $result)
        {
            Write-Host "$($item.Name) $($item.Version)"
        }
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

function Test-Remove-ModulesPrevious {
    param()
    [bool]$retval = $false;
    try {
        $result = CoreePower.Common\Remove-ModulesPrevious -ModuleNames @("CoreePower.Lib")
        foreach ($item in $result)
        {
            Write-Host "$($item.Name) $($item.Version)"
        }
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

function Test-Remove-Modules {
    param()
    [bool]$retval = $false;
    try {
        $result = CoreePower.Common\Remove-Modules -ModuleNames @("CoreePower.Config")
        foreach ($item in $result)
        {
            Write-Host "$($item.Name) $($item.Version)"
        }
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

function Test-Update-ModulesLatest {
    param()
    [bool]$retval = $false;
    try {
        $result = CoreePower.Common\Update-ModulesLatest -ModuleNames @('Coree*')
        foreach ($item in $result)
        {
            Write-Host "$($item.Name) $($item.Version)"
        }
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

function Test-Get-CurrentModule {
    param()
    [bool]$retval = $false;
    try {
        $moduleName , $moduleVersion =  CoreePower.Common\Get-CurrentModule
        Write-Host "$($moduleName) $($moduleVersion)"
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
