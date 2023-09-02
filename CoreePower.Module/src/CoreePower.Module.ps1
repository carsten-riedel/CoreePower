<#
.SYNOPSIS
    Recursively copies files and directories from a source directory to a destination directory.

.DESCRIPTION
    The `Copy-Recursive` function allows you to copy files and directories from a specified source directory to a destination directory. It performs a recursive copy operation, preserving the directory structure of the source directory.

.PARAMETER Source
    Specifies the path to the source directory. This is the directory from which files and directories will be copied.

.PARAMETER Destination
    Specifies the path to the destination directory. This is the directory where the files and directories from the source directory will be copied to.

.NOTES
    - This function performs a recursive copy, copying all files and directories from the source directory to the destination directory.
    - The directory structure of the source directory is preserved in the destination directory.
    - If the destination directory does not exist, it will be created.
    - If a file or directory with the same name already exists in the destination directory, it will be overwritten.
    - The function accepts the alias 'copyrec' for easier use.

.EXAMPLE
    PS C:\> Copy-Recursive -Source 'C:\SourceFolder' -Destination 'C:\DestinationFolder'

    This example copies all files and directories from 'C:\SourceFolder' to 'C:\DestinationFolder', preserving the directory structure.
#>
function Copy-Recursive {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("copyrec")] 
    param (
        [string]$Source,
        [string]$Destination
    )

    New-Directory -Directory $Destination

    Get-ChildItem $Source -Recurse | Foreach-Object {
        $targetPath = $_.FullName -replace [regex]::Escape($Source), $Destination
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        }
        else {
            Copy-Item $_.FullName -Destination $targetPath -Force | Out-Null
        }
    }
}

<#
.SYNOPSIS
    Creates a new temporary directory in the AppData\Local\Temp directory.

.DESCRIPTION
    The `New-TempDirectory` function creates a new temporary directory in the AppData\Local\Temp directory. It generates a unique identifier using `[System.Guid]::NewGuid().ToString()` and combines it with the AppData\Local\Temp path to create a unique directory path. If the directory does not exist, it is created using `New-Item`.

.NOTES
    - The function provides a convenient way to generate and create a new temporary directory.
    - The generated temporary directory path is returned as the output.
    - This function uses the `LocalApplicationData` folder within the AppData directory to ensure the creation of the temporary directory in the user's local application data.
    - The function accepts the alias 'newtmpdir' for easier use.
    
.EXAMPLE
    PS C:\> New-TempDirectory

    This example creates a new temporary directory in the AppData\Local\Temp directory and returns the path of the newly created directory.
#>
function New-TempDirectory {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [Alias("newtmpdir")]
    param ()

    $tempDirectoryPath = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Temp' | Join-Path -ChildPath ([System.Guid]::NewGuid().ToString())
    if (-not (Test-Path $tempDirectoryPath)) {
        New-Item -ItemType Directory -Path $tempDirectoryPath -Force | Out-Null
    }

    return $tempDirectoryPath
}

function New-Directory {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    if (-not(Test-Path -Path $Directory -PathType Container)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }

    if (Test-Path -Path $Directory -PathType Leaf) {
        $Directory = [System.IO.Path]::GetDirectoryName($Directory)
        $Directory = New-Directory -Directory $Directory
    }

    return $Directory
}

function Remove-TempDirectory {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [Alias("rmtmpdir")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TempDirectory
    )
 
    if (Test-Path -Path $TempDirectory -PathType Container) {
        Remove-Item -Path "$TempDirectory" -Recurse -Force
    }

    if (Test-Path -Path $TempDirectory -PathType Leaf) {
        $TempDirectory = [System.IO.Path]::GetDirectoryName($TempDirectory)
        $guidPattern = "\\[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
        if ($TempDirectory -match $guidPattern) {
            # Removing parent directory recursively if it is a guid pattern
            Remove-Item -Path "$TempDirectory" -Recurse -Force
        }
    }

}




function Merge-Hashtable($target, $source) {
    $source.Keys | ForEach-Object {
        $key = $_
        if (-not $target.ContainsKey($key)) {
            # Add new key-value pairs
            $target[$key] = $source[$key]
        } elseif ($target[$key] -eq '' -and $source[$key] -ne '') {
            # Overwrite the value when target key's value is empty
            $target[$key] = $source[$key]
        } elseif ($source[$key] -is [Hashtable]) {
            # Merge nested hashtables
            Merge-Hashtable $target[$key] $source[$key]
        }
    }
}

# Modify Merge-Object function to handle nested hashtables
function Merge-Object($target, $source) {
    $source.PSObject.Properties | ForEach-Object {
        $propertyName = $_.Name
        $propertyValue = $_.Value

        if ($target.PSObject.Properties.Name.Contains($propertyName)) {
            if ($propertyValue -is [PSCustomObject]) {
                # Initialize the target property if it's null
                if ($null -eq $target.$propertyName) {
                    $target.$propertyName = [PSCustomObject]@{}
                }
                Merge-Object $target.$propertyName $propertyValue
            } elseif ($propertyValue -is [Array]) {
                # Merge arrays
                $target.$propertyName += $propertyValue
            } elseif ($propertyValue -is [Hashtable]) {
                # Merge hashtables
                if ($null -eq $target.$propertyName) {
                    $target.$propertyName = @{}
                }
                Merge-Hashtable $target.$propertyName $propertyValue
            }
        } else {
            $target | Add-Member -MemberType $_.MemberType -Name $propertyName -Value $propertyValue
        }
    }
}

function Convert-JsonToPowerShellNotation {
    [alias("cjpn")] 
    param (
        [Parameter(Mandatory=$true)]
        [string]$JsonString
    )

    function Convert-ObjectToPowerShellNotation {
        param (
            [Parameter(Mandatory=$true)]
            [PSObject]$InputObject
        )

        $outputString = '@{ '

        foreach ($property in $InputObject.PSObject.Properties) {
            $key = $property.Name
            $value = $property.Value

            if ($value -is [string]) {
                $outputString += "$key = '$value'; "
            } elseif ($value -is [bool]) {
                $outputString += "$key = $([bool]::ToString($value).ToLower()); "
            } elseif ($value -is [array]) {
                $outputString += "$key = @($(Convert-ArrayToPowerShellNotation -InputArray $value)); "
            } else {
                $outputString += "$key = $(Convert-ObjectToPowerShellNotation -InputObject $value); "
            }
        }

        $outputString = $outputString.TrimEnd('; ')
        $outputString += ' }'

        return $outputString
    }

    function Convert-ArrayToPowerShellNotation {
        param (
            [Parameter(Mandatory=$true)]
            [array]$InputArray
        )

        $outputString = ""

        foreach ($element in $InputArray) {
            if ($element -is [string]) {
                $outputString += "'$element', `n"
            } elseif ($element -is [bool]) {
                $outputString += "$([bool]::ToString($element).ToLower()), `n"
            } elseif ($element -is [array]) {
                $outputString += "@($(Convert-ArrayToPowerShellNotation -InputArray $element)), `n"
            } else {
                $outputString += "$(Convert-ObjectToPowerShellNotation -InputObject $element), `n"
            }
        }

        $outputString = $outputString.TrimEnd(', ')

        return $outputString
    }

    try {
        $PowerShellObject = $JsonString | ConvertFrom-Json
    }
    catch {
        Write-Error "Failed to convert JSON string to PowerShell object. Please ensure the input is a valid JSON string."
        return
    }

    if ($PowerShellObject -is [array]) {
        return "@($(Convert-ArrayToPowerShellNotation -InputArray $PowerShellObject))"
    } else {
        return (Convert-ObjectToPowerShellNotation -InputObject $PowerShellObject)
    }
}

function Convert-JsonToPowerShellNotation2 {
    param (
        [Parameter(Mandatory=$true)]
        [string]$JsonString
    )

    function Convert-ObjectToPowerShellNotation2 {
        param (
            [Parameter(Mandatory=$true)]
            [PSObject]$InputObject,
            [int]$Indent = 0
        )

        $indentation = " " * $Indent
        $outputString = "@{" + [Environment]::NewLine

        foreach ($property in $InputObject.PSObject.Properties) {
            $key = $property.Name
            $value = $property.Value

            if ($value -is [string]) {
                $outputString += "$indentation$key = '$value';" + [Environment]::NewLine
            } elseif ($value -is [bool]) {
                $outputString += "$indentation$key = $([bool]::ToString($value).ToLower());" + [Environment]::NewLine
            } elseif ($value -is [array]) {
                $outputString += "$indentation$key = @(" + [Environment]::NewLine
                $outputString += "$(Convert-ArrayToPowerShellNotation2 -InputArray $value -Indent ($Indent + 4))" + [Environment]::NewLine
                $outputString += "$indentation);" + [Environment]::NewLine
            } else {
                $outputString += "$indentation$key = $(Convert-ObjectToPowerShellNotation2 -InputObject $value -Indent ($Indent + 4));" + [Environment]::NewLine
            }
        }

        $outputString += $indentation + '}'

        return $outputString
    }

    function Convert-ArrayToPowerShellNotation2 {
        param (
            [Parameter(Mandatory=$true)]
            [array]$InputArray,
            [int]$Indent = 0
        )

        $indentation = " " * $Indent
        $outputString = ""

        foreach ($element in $InputArray) {
            if ($element -is [string]) {
                $outputString += $indentation + "'$element'," + [Environment]::NewLine
            } elseif ($element -is [bool]) {
                $outputString += $indentation + "$([bool]::ToString($element).ToLower())," + [Environment]::NewLine
            } elseif ($element -is [array]) {
                $outputString += $indentation + "@(" + [Environment]::NewLine
                $outputString += "$(Convert-ArrayToPowerShellNotation2 -InputArray $element -Indent ($Indent + 4))" + [Environment]::NewLine
                $outputString += $indentation + ")," + [Environment]::NewLine
            } else {
                $outputString += $indentation + "$(Convert-ObjectToPowerShellNotation2 -InputObject $element -Indent ($Indent + 4))," + [Environment]::NewLine
            }
        }

        $outputString = $outputString.TrimEnd(",`n")

        return $outputString
    }

    try {
        $PowerShellObject = $JsonString | ConvertFrom-Json
    }
    catch {
        Write-Error "Failed to convert JSON string to PowerShell object. Please ensure the input is a valid JSON string."
        return
    }
    
    if ($PowerShellObject -is [array]) {
        return "@(`n$(Convert-ArrayToPowerShellNotation2 -InputArray $PowerShellObject)`n)"
    } else {
        return (Convert-ObjectToPowerShellNotation2 -InputObject $PowerShellObject)
    }
}





function ListModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cplm")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    Write-Output "List the currently installed modules versions on your computer.`n"
    Get-Module -ListAvailable "$Name" | Format-Table -AutoSize

    Write-Output "Displays function/commands loaded in your current session.`n"
    Get-Command -Module "$Name" -All | Sort-Object -Property @{Expression = 'Source' ; Ascending = $true }, @{ Expression = 'Version' ; Descending = $true}, @{ Expression = 'CommandType' ; Descending = $true} | Select-Object Source, Version , CommandType , Name | Format-Table -AutoSize

    Write-Output "Displays the latest online version available.`n"
    #Find-Module -Name "$Name"
}




<#
function Expand-NuGetPackage {
    param(
        [string]$nugetPackageName,
        [string]$extractPath
    )

    # Check if NuGet package source is registered
    $nugetSource = Get-PackageSource -Name "NuGet" -ErrorAction SilentlyContinue
    if (-not $nugetSource) {
        Register-PackageSource -Name "NuGet" -Location "https://api.nuget.org/v3/index.json" -ProviderName NuGet
    }

    # Install NuGet.CommandLine package
    $package = Get-Package -Name $nugetPackageName -ProviderName NuGet -Scope CurrentUser -ErrorAction SilentlyContinue
    if (-not $package) {
        Install-Package -Name $nugetPackageName -ProviderName NuGet -Scope CurrentUser -Force
        $package = Get-Package -Name $nugetPackageName -ProviderName NuGet -Scope CurrentUser -ErrorAction SilentlyContinue
    }
    $packagePath = $package | Select-Object -ExpandProperty Source

    # Extract package to temp directory
    $tempPath = [System.IO.Path]::GetTempFileName() + ".zip"
    Copy-Item $packagePath $tempPath
    Rename-Item $tempPath -NewName "$tempPath.zip"
    if (-not (Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath | Out-Null
    }
    Expand-Archive -Path "$tempPath.zip" -DestinationPath $extractPath -Force
    Remove-Item "$tempPath.zip"
}

function Copy-SubfoldersToDestination2 {
    param (
        [string]$SourceFolder,
        [string[]]$Subfolders,
        [string]$DestinationFolder
    )

    foreach ($subfolder in $Subfolders) {
        $subfolderPath = Join-Path $SourceFolder $subfolder

        Copy-Item $subfolderPath -Destination $DestinationFolder -Recurse -Force
    }
}

function Copy-SubfoldersToDestination {
    param (
        [string]$SourceFolder,
        [string[]]$Subfolders,
        [string]$DestinationFolder
    )

    foreach ($subfolder in $Subfolders) {
        $subfolderPath = Join-Path $SourceFolder $subfolder
        Get-ChildItem $subfolderPath -Recurse | 
            Where-Object {!$_.PSIsContainer} | 
            Copy-Item -Destination $DestinationFolder -Force
    }
}


Expand-NuGetPackage -nugetPackageName "Coree.NuPack" -extractPath "C:\temp\foox"
Copy-SubfoldersToDestination -Subfolders @('tools','ProjectPath') -SourceFolder "C:\temp\foox" -DestinationFolder 'C:\temp\yo'
#>


################################################################################


<#
$owner = "carsten-riedel"
$repo = "CoreePower.Config"
$path = "."


$url = "https://api.github.com/repos/$owner/$repo/contents/$path"
$response = Invoke-RestMethod -Uri $url -Method Get

foreach ($file in $response) {
    Write-Host $file.name
}

function Get-GitHubDirectoryContents {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Owner,
        [Parameter(Mandatory = $true)]
        [string]$Repo,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$Ref = 'master'
    )

    $uri = "https://api.github.com/repos/$($Owner)/$($Repo)/contents/$($Path)?ref=$($Ref)"
    $response = Invoke-RestMethod -Uri $uri

    foreach ($item in $response) {
        if ($item.type -eq 'dir') {
            # Recursively get contents of subdirectory
            Get-GitHubDirectoryContents -Owner $Owner -Repo $Repo -Path $item.path -Ref $Ref
        }
        else {
            # Output file path
            Write-Output $item.path
        }
    }
}

function Get-GitHubFileContent {
    param (
        [string]$Owner,
        [string]$Repo,
        [string]$Path,
        [string]$Branch = 'main'
    )

    $url = "https://api.github.com/repos/$Owner/$Repo/contents/$($Path)?ref=$($Branch)"

    $response = Invoke-RestMethod -Method Get -Uri $url

    if ($response.type -eq 'file') {
        $content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($response.content))
        return $content
    }
    else {
        Write-Error 'The specified path does not point to a file.'
    }
}


Get-GitHubDirectoryContents -Repo $repo -Owner $owner -Path $path -Ref "main"
Get-GitHubFileContent -Repo $repo -Owner $owner -Path "src/CoreePower.Config/CoreePower.Config.EnviromentVariable.ps1" -Branch "main"
#>


<#

$roots = @("C:\temp", "C:\Windows") ; $roots | ForEach-Object { Get-ChildItem -Path $_ -Filter "nuget*" -Recurse -ErrorAction SilentlyContinue } | Where-Object {!$_.PSIsContainer} | Select-Object -ExpandProperty FullName

$roots = @("D:\", "E:\") ; $roots | ForEach-Object { Get-ChildItem -Path $_ -Include @("*.mkv","*.mp4") -Recurse -ErrorAction SilentlyContinue } | Where-Object {!$_.PSIsContainer -and $_.Length -gt 1000000 } | Select-Object -ExpandProperty FullName

$roots = @("C:\","D:\", "E:\") ; $roots | ForEach-Object { Get-ChildItem -Path $_ -Include @("*.txt","*.md") -Recurse -ErrorAction SilentlyContinue } | Where-Object {!$_.PSIsContainer -and $_.Length -lt 10000 } | Where-Object { (Get-Content $_.FullName -Raw) -match "hello" } | Select-Object -ExpandProperty FullName

$roots = @("$($env:USERPROFILE)\source\repos", "C:\VCS" , "C:\base") ; $roots | ForEach-Object { Get-ChildItem -Path $_ -Include @("*.cs") -Recurse -ErrorAction SilentlyContinue } | Where-Object {!$_.PSIsContainer -and $_.Length -lt 100000 } | Where-Object { (Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue) -match "power" } | Select-Object -ExpandProperty FullName

#>
