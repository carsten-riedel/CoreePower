$dir = $PSScriptRoot
Set-Location -Path "$dir/../.."
$workspaceFolder = Get-Location

$dotnetdir = Join-Path -Path "$workspaceFolder" -ChildPath "source/CoreePower.Net/src/CoreePower.Net"
$artifacts = Join-Path -Path "$workspaceFolder" -ChildPath "artifacts" -AdditionalChildPath @("bin")

Set-Location -Path $dotnetdir

#dotnet clean --configuration "Release" --framework "net461" --property:TargetFrameworks="net461" & dotnet publish --configuration "Release" --framework "net461" --property:TargetFrameworks="net461" --property:DefineConstants="net461" --output "bin\Publish\net461" --force

&dotnet clean `
  --configuration:"Debug" `
  --framework:"netstandard2.0" `
  --property:"TargetFrameworks=`"netstandard2.0`""

&dotnet publish `
  --force `
  --configuration:"Debug" `
  --framework:"netstandard2.0" `
  --property:"TargetFrameworks=`"netstandard2.0`"" `
  --output:"$artifacts" 
  

Set-Location -Path $workspaceFolder