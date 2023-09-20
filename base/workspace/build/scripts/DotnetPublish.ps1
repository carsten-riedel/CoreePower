$dir = $PSScriptRoot
Set-Location -Path "$dir/../.."
$workspaceFolder = Get-Location

$dotnetdir = Join-Path -Path "$workspaceFolder" -ChildPath "source" -AdditionalChildPath @("CoreePower.Net","src","CoreePower.Net")
$artifacts = Join-Path -Path "$workspaceFolder" -ChildPath "artifacts" -AdditionalChildPath @("bin")

Set-Location -Path $dotnetdir

$frameworkOverride = "netstandard2.0"
$output = Join-Path -Path "$artifacts" -ChildPath "$frameworkOverride"

&dotnet clean `
  --configuration:"Release" `
  --framework:"$frameworkOverride" `
  --property:"TargetFrameworks=`"$frameworkOverride`""

&dotnet publish `
  --force `
  --configuration:"Release" `
  --framework:"$frameworkOverride" `
  --property:"TargetFrameworks=`"$frameworkOverride`"" `
  --output:"$output" `
  --maxcpucount:1
  

Set-Location -Path $workspaceFolder