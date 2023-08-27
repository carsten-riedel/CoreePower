Write-Host "$($MyInvocation.MyCommand.Name) called in Mode: $Mode"

Import-Module "C:\base\github.com\carsten-riedel\CoreePower\CoreePower.Common\src\CoreePower.Common.psm1" -Force -Verbose

. "$PSScriptRoot\RunnerTests.ps1"

$retvals = @()
$retval = $false

#Add addtional test functions here
$functionName = "Test-Write-Notice"; $retval = & $functionName;if ($retval -is [array]) { $retval = $retval[-1] }; $retvals += @{ FunctionName = $functionName; Result = $retval };

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