

function SetRegistryValue {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("")]
    param(
        [string]$regPath,
        [string]$valueName,
        [string]$expectedValue
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope [Scope]::LocalMachine))
    {
        return
    }

    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Passwordless\Device"
    $valueName = "DevicePasswordLessBuildVersion"
    $expectedValue = "00000000"
    
    # Check if the registry value exists and has the expected value
    $currentValue = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName
    if ($currentValue -ne $expectedValue)
    {
        # Set the registry value to the expected value
        Set-ItemProperty -Path $regPath -Name $valueName -Value $expectedValue
        Write-Host "Registry value '$valueName' set to '$expectedValue'"
    }
    else
    {
        Write-Host "Registry value '$valueName' already set to '$expectedValue'"
    }
}

function Enable-WindowsHelloLogon {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("")]
    param()

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope [Scope]::LocalMachine))
    {
        return
    }

    SetRegistryValue -regPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Passwordless\Device" -valueName "DevicePasswordLessBuildVersion" -expectedValue "00000002"

}

function Disable-WindowsHelloLogon {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("")]
    param()

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope [Scope]::LocalMachine))
    {
        return
    }

    SetRegistryValue -regPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Passwordless\Device" -valueName "DevicePasswordLessBuildVersion" -expectedValue "00000002"
}