dotnet restore
dotnet build

if ($null -eq $IsWindows)
{
    $global:IsWindows = $true
    $global:IsLinux = $false
    $global:IsMacOS = $false
}

if ($PSVersionTable.PSVersion.Major -ge 6) {
    $global:IsCore = $true
    $global:IsDesktop = $false
}
else {
    $global:IsCore = $false
    $global:IsDesktop =  = $true
}



Write-Output "$IsWindows $IsCore $IsLinux $IsDesktop"