
# Determine which version of .NET Framework/.NET Core is available
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PowerShell 7.x, .NET Core / .NET 5+
    Import-Module -Name "$PSScriptRoot/netstandard2.0/CoreePower.Net.dll"
}
elseif ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSEdition -eq 'Desktop') {
    # Windows PowerShell 5.x
    Import-Module -Name "$PSScriptRoot/net461/CoreePower.Net.dll"
}
else {
    Write-Error "Unsupported PowerShell version."
    return
}