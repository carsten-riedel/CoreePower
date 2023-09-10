
#https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell?view=powershell-7.3
#https://learn.microsoft.com/en-us/dotnet/standard/frameworks
#https://learn.microsoft.com/en-us/dotnet/standard/net-standard?tabs=net-standard-2-1#net-implementation-support
#https://learn.microsoft.com/en-us/powershell/scripting/install/powershell-support-lifecycle?view=powershell-7.3

#PowerShell 7.3 - Built on .NET 7.0
#PowerShell 7.2 (LTS-current) - Built on .NET 6.0 (LTS-current)
#PowerShell 7.1 - Built on .NET 5.0
#PowerShell 7.0 (LTS) - Built on .NET Core 3.1 (LTS)
#PowerShell 6.2 - Built on .NET Core 2.1
#PowerShell 6.1 - Built on .NET Core 2.1
#PowerShell 6.0 - Built on .NET Core 2.0

# Conclusion all versions of powerhsell core support at least netstandard2 -> (6.0 - Built on .NET Core 2.0)
# Conclusion all versions of powerhsell windows support at least net452
# Conclusion net462 for powerhsell windows and the following will the always netstandard2 never netstandard21

function Get-SystemNetFrameworkVersionsCapabilities {
    # Get the release key from registry
    $release = Get-ItemPropertyValue -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release

    # Create an array of known release keys and versions
    $items = @(
        [PSCustomObject]@{ Release = 533320; Version = '4.8.1'; VersionValue = '4.8.1'; TargetFrameworkMoniker = 'net481' },
        [PSCustomObject]@{ Release = 528040; Version = '4.8'; VersionValue = '4.8'; TargetFrameworkMoniker = 'net48' },
        [PSCustomObject]@{ Release = 461808; Version = '4.7.2'; VersionValue = '4.7.2'; TargetFrameworkMoniker = 'net472' },
        [PSCustomObject]@{ Release = 461308; Version = '4.7.1'; VersionValue = '4.7.1'; TargetFrameworkMoniker = 'net471' },
        [PSCustomObject]@{ Release = 460798; Version = '4.7'; VersionValue = '4.7'; TargetFrameworkMoniker = 'net47' },
        [PSCustomObject]@{ Release = 394802; Version = '4.6.2'; VersionValue = '4.6.2'; TargetFrameworkMoniker = 'net462' },
        [PSCustomObject]@{ Release = 394254; Version = '4.6.1'; VersionValue = '4.6.1'; TargetFrameworkMoniker = 'net461' },
        [PSCustomObject]@{ Release = 393295; Version = '4.6'; VersionValue = '4.6'; TargetFrameworkMoniker = 'net46' },
        [PSCustomObject]@{ Release = 379893; Version = '4.5.2'; VersionValue = '4.5.2'; TargetFrameworkMoniker = 'net452' }
    )

    # Identify the installed and lower versions based on the release key
    $possibleVersions = $items | Where-Object { $_.Release -le $release } | Sort-Object -Property Release -Descending

    if ($possibleVersions.Count -gt 0) {
        return $possibleVersions
    } else {
        return $null
    }
}

function Get-SystemNetCapabilities {
    param (
    )

    $version = $PSVersionTable.PSVersion

    #PowerShell 7.3 - Built on .NET 7.0
#PowerShell 7.2 (LTS-current) - Built on .NET 6.0 (LTS-current)
#PowerShell 7.1 - Built on .NET 5.0
#PowerShell 7.0 (LTS) - Built on .NET Core 3.1 (LTS)
#PowerShell 6.2 - Built on .NET Core 2.1
#PowerShell 6.1 - Built on .NET Core 2.1
#PowerShell 6.0 - Built on .NET Core 2.0

    # Create an array of known release keys and versions
    $items = @(
        [PSCustomObject]@{ Major = 7 ; Minor = 3;  TargetFrameworkMoniker = 'net7' },
        [PSCustomObject]@{ Major = 7 ; Minor = 2;  TargetFrameworkMoniker = 'net6' },
        [PSCustomObject]@{ Major = 7 ; Minor = 1;  TargetFrameworkMoniker = 'net5' },
        [PSCustomObject]@{ Major = 7 ; Minor = 0;  TargetFrameworkMoniker = 'netcoreapp3.1' },
        [PSCustomObject]@{ Major = 7 ; Minor = 0;  TargetFrameworkMoniker = 'netstandard2.1' },
        [PSCustomObject]@{ Major = 6 ; Minor = 2;  TargetFrameworkMoniker = 'netcoreapp2.1' },
        [PSCustomObject]@{ Major = 6 ; Minor = 2;  TargetFrameworkMoniker = 'netstandard2.1' },
        [PSCustomObject]@{ Major = 6 ; Minor = 1;  TargetFrameworkMoniker = 'netcoreapp2.1' },
        [PSCustomObject]@{ Major = 6 ; Minor = 1;  TargetFrameworkMoniker = 'netstandard2.1' },
        [PSCustomObject]@{ Major = 6 ; Minor = 0;  TargetFrameworkMoniker = 'netcoreapp2.0' }
        [PSCustomObject]@{ Major = 6 ; Minor = 0;  TargetFrameworkMoniker = 'netstandard2.0' }
    )

    $possibleVersions = $items | Where-Object {
        ($_.Major -lt $version.Major) -or (($_.Major -eq $version.Major) -and ($_.Minor -le $version.Minor))
    } | Sort-Object @{Expression = 'Major'; Descending = $true}, @{Expression = 'Minor'; Descending = $true}

    if ($possibleVersions.Count -gt 0) {
        return $possibleVersions
    } else {
        return $null
    }
}

function Find-NetFrameworkSubdirectory {
    param (
        [string]$basePath,
        [array]$possibleVersions,
        [string]$AssemblyName
    )

    if ($possibleVersions -eq $null) {
        return $null
    }

    # Iterate through the possible versions to find a matching subdirectory
    foreach ($version in $possibleVersions) {
        $subDirPath = Join-Path -Path $basePath -ChildPath $version.TargetFrameworkMoniker
        $assemblyPath = Join-Path -Path $subDirPath -ChildPath $AssemblyName

        if (Test-Path -Path $subDirPath -PathType Container) {
            if (Test-Path -Path $assemblyPath -PathType Leaf) {
                return $assemblyPath
            }
        }
    }

    $plainbase = Join-Path -Path $basePath -ChildPath $AssemblyName

    if (Test-Path -Path $plainbase -PathType Leaf) {
        return $plainbase
    } else {
        return $null
    }
}


$AssemblyName = "CoreePower.Net.dll"
$SearchRoot= "$PSScriptRoot"

# Determine which version of .NET Framework/.NET Core is available
if ($PSVersionTable.PSVersion.Major -ge 6 -and $PSVersionTable.PSEdition -eq 'Core') {
    
    # PowerShell 7.x 6.x, .NET Core / .NET 5+
    $ModuleFile = Find-NetFrameworkSubdirectory -basePath "$SearchRoot" -possibleVersions $(Get-SystemNetCapabilities) -AssemblyName $AssemblyName
    if ($null -ne $ModuleFile) {
        Import-Module -Name "$ModuleFile" -Force
    } else {
        Write-Host "No matching subdirectories found."
    }
}
elseif ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSEdition -eq 'Desktop') {
    # Windows PowerShell 5.x
    $ModuleFile = Find-NetFrameworkSubdirectory -basePath "$SearchRoot" -possibleVersions $(Get-SystemNetFrameworkVersionsCapabilities) -AssemblyName $AssemblyName
    if ($null -ne $ModuleFile) {
        Import-Module -Name "$ModuleFile"
    } else {
        Write-Host "No matching subdirectories found."
    }

}
else {
    Write-Error "Unsupported PowerShell version."
    return
}


