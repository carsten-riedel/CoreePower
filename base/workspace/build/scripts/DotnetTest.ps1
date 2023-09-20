$dir = $PSScriptRoot
Set-Location -Path "$dir/../.."
$workspaceFolder = Get-Location

$dotnetdir = Join-Path -Path "$workspaceFolder" -ChildPath "source" -AdditionalChildPath @("CoreePower.Net")
$LogReportRoot = Join-Path -Path "$workspaceFolder" -ChildPath "artifacts" -AdditionalChildPath @("dotnettest")

Set-Location -Path $dotnetdir

&dotnet test `
  --logger:"trx;LogFilename=$LogReportRoot\Logger\Testlogger.trx" `
  --logger:"html;LogFilename=$LogReportRoot\Logger\Testlogger.html" `
  --consoleloggerparameters:Summary `
  --verbosity:minimal `
  --results-directory:"$LogReportRoot\temptest" `
  --collect:"XPlat Code Coverage" `
  --property:"CollectCoverage=true" `
  --property:"CoverletOutput=`"$LogReportRoot\Coverage\coverlet`"" `
  --property:"CoverletOutputFormat=`"opencover,cobertura,json,lcov`"" `
  --property:"ReportGeneratorPath=`"$LogReportRoot\Report`"" `
  


Set-Location -Path $workspaceFolder

$resultindex = Invoke-Prompt -PromptTitle "Select action" -PromptMessage "Testcoverage" -PromptChoices @(@('&Cancel', 'Cancel the action.'), @('&Publish', 'Publish the result.'))


