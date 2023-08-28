
Write-Host "RunnerImports: $($MyInvocation.MyCommand.Source) called in Mode: $Mode"

$parent = (Get-Item ([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path))).Parent
$import = $parent.FullName +"\src\$($parent.Name).$($Mode)1"

$reqmods = (ReadModulePsd -SearchRoot "$import").RequiredModules

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

Import-Module "$import" -Force
Write-Host "Imported Module: $import"

. "$PSScriptRoot\RunnerTests.ps1"
Write-Host "Dot sourced tests: $($PSScriptRoot)\RunnerTests.ps1"

$retvals = @()
$retval = $false

#Add addtional test functions here
$functionName = "Test-Write-Notice"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Write-FormatedText"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Invoke-Prompt"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Confirm-AdminRightsEnabled"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-CanExecuteInDesiredScope"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-CouldRunAsAdministrator"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Get-ModulesInfoExtended"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Get-ModulesLocal"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
#$functionName = "Test-Get-ModulesUpdatable"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Remove-ModulesPrevious"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Remove-Modules"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
#$functionName = "Test-Update-ModulesLatest"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };
$functionName = "Test-Get-CurrentModule"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };




# 'Remove-ModulesPrevious', 'Remove-Modules', 'Update-ModulesLatest', 'Get-CurrentModule'

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