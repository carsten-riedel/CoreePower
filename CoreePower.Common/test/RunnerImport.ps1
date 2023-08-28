
Write-Host "RunnerImports: $($MyInvocation.MyCommand.Source) called in Mode: $Mode"

$parent = (Get-Item ([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path))).Parent
$import = $parent.FullName +"\src\$($parent.Name).$($Mode)1"

Save-Module -Name "$import" -Path "C:\temp"
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