
Write-Host "RunnerImports: $($MyInvocation.MyCommand.Source) called in Mode: $Mode"

$parent = (Get-Item ([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path))).Parent
$import = $parent.FullName +"\src\$($parent.Name).psd1"
$psd = ReadPsdx -FullName "$import"

$reqmods = ($psd).RequiredModules

foreach ($item in $reqmods)
{
    $module = Get-Module -ListAvailable -Name $item.ModuleName | Sort-Object Version -Descending | Select-Object -First 1

    if ($module) {
        if ($module.Version -ge $item.ModuleVersion) {
            Write-Host "The module is available and meets the minimum version requirement."
        } else {
            Install-Module -Name "$($item.ModuleName)" -Force
        }
    } else {
        Install-Module -Name "$($item.ModuleName)" -Force
    }
   
}

Import-Module "$($psd.PSDDirectoryName)\$($psd.RootModule)" -Force
Write-Host "Imported Module: $import"

. "$PSScriptRoot\RunnerTests.ps1"
Write-Host "Dot sourced tests: $($PSScriptRoot)\RunnerTests.ps1"

$retvals = @()
$retval = $false

#Add addtional test functions here
$functionName = "Test-Initialize-PowerShellGet"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Initialize-PackageManagement"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Initialize-DevTools7z"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Initialize-DevToolsMsOpenjdk17"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Initialize-DevToolsVsCode"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };

$allSucceeded = $true

# Iterate over the $retvals array and show results
$retvals | ForEach-Object {
    if ($_.Result) {
        Write-Output "$($_.FunctionName) succeeded."
    } else {
        Write-Output "$($_.FunctionName) failed."
        $allSucceeded = $false
    }
}

if ($allSucceeded)
{
    Write-Output "allSucceeded."
}