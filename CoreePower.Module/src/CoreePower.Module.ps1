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


function PublishModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cppm")]   
    param(
        [string] $Path = ""
    )

    if ($Path -eq "")
    {
        $loc = Get-Location
        $Path = $loc.Path
    }

    $Path = $Path.TrimEnd('\')

    $LastDirectory = Split-Path -Path $Path -Leaf
    $psd1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" } | Select-Object BaseName
    $psm1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psm1" } | Select-Object BaseName

    if($psd1BaseName.Count -eq 0)
    {
        Write-Error "Error: no powerShell module manifest files found. Please ensure that there is one .psd1 file in the directory and try again."
        return
    }

    if($psm1BaseName.Count -eq 0)
    {
        Write-Error "Error: no root module files found. Please ensure that there is one .psm1 file in the directory and try again."
        return
    }

    if($psd1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psd1 file in the directory and try again."
        return
    }

    if($psm1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psm1 file in the directory and try again."
        return
    }

    if($LastDirectory -eq $psd1BaseName -and $psd1BaseName -eq $psm1BaseName)
    {
        Write-Error "Error: The parent directory name, .psd1 filename, and .psm1 filename must all be identical. Please ensure that all three names match and try again."
        return
    }


    $keyFileFullName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Name -eq ".key" } | Select-Object FullName
    if($null -eq $keyFileFullName)
    {
        Write-Error  "Error: A .key file containing the NuGet API key is missing from the publish directory. Please add the file and try again."
        return
    }

    $gitignoreFullName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Name -eq ".gitignore" } | Select-Object FullName
    if($null -eq $gitignoreFullName)
    {
        Write-Warning  "Warning: A .gitignore file is not present, the NuGet API key may be exposed in the publish directory. Please include a .gitignore file with ignore statements for the key to prevent unauthorized access."
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    #Initialize-PowerShellGetLatest
    #Initialize-PackageManagementLatest

    [string]$NuGetAPIKey = Get-Content -Path "$($keyFileFullName.FullName)"

    Publish-Module -Path "$Path" -NuGetApiKey "$NuGetAPIKey" -Repository "PSGallery" -Verbose

}

function PublishModule2 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cppm2")]   
    param(
        [string] $Path = ""
    )

    if ($Path -eq "")
    {
        $loc = Get-Location
        $Path = $loc.Path
    }

    $Path = $Path.TrimEnd('\')

    $LastDirectory = Split-Path -Path $Path -Leaf
    $psd1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" } | Select-Object BaseName
    $psm1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psm1" } | Select-Object BaseName

    if($psd1BaseName.Count -eq 0)
    {
        Write-Error "Error: no powerShell module manifest files found. Please ensure that there is one .psd1 file in the directory and try again."
        return
    }

    if($psm1BaseName.Count -eq 0)
    {
        Write-Error "Error: no root module files found. Please ensure that there is one .psm1 file in the directory and try again."
        return
    }

    if($psd1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psd1 file in the directory and try again."
        return
    }

    if($psm1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psm1 file in the directory and try again."
        return
    }

    if($LastDirectory -eq $psd1BaseName -and $psd1BaseName -eq $psm1BaseName)
    {
        Write-Error "Error: The parent directory name, .psd1 filename, and .psm1 filename must all be identical. Please ensure that all three names match and try again."
        return
    }


    $keyFileFullName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Name -eq ".key" } | Select-Object FullName
    if($null -eq $keyFileFullName)
    {
        Write-Error  "Error: A .key file containing the NuGet API key is missing from the publish directory. Please add the file and try again."
        return
    }

    $gitignoreFullName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Name -eq ".gitignore" } | Select-Object FullName
    if($null -eq $gitignoreFullName)
    {
        Write-Warning  "Warning: A .gitignore file is not present, the NuGet API key may be exposed in the publish directory. Please include a .gitignore file with ignore statements for the key to prevent unauthorized access."
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    #Initialize-PowerShellGetLatest
    #Initialize-PackageManagementLatest

    [string]$NuGetAPIKey = Get-Content -Path "$($keyFileFullName.FullName)"

    
    $fullname = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" }

    $fileContent = Get-Content -Path "$($fullname.FullName)" -Raw
    $index = $fileContent.IndexOf("@{")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }
    $index = $fileContent.LastIndexOf("}")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }

    $Data  = Invoke-Expression "[PSCustomObject]@{$fileContent}"

    try {
        
        Publish-Module -Path "$Path" -NuGetApiKey "$NuGetAPIKey" -Repository "PSGallery" -Verbose

        $moduleName = Split-Path $MyInvocation.MyCommand.Module.Name -Leaf
        $moduleVersion = $MyInvocation.MyCommand.Module.Version
        Write-Output "Publish with $moduleName $moduleVersion."

        $executable = Get-Command "git" -ErrorAction SilentlyContinue
        
        [string]$NameRoot = $Data.RootModule
        $NameRoot = $NameRoot -replace '\.psm1$'

        if ($executable) {
            Write-Output "Git executable found at $($executable.Source) automatic git add -A, commit and push."
            &git -C "$Path" add -A
            &git -C "$Path" commit -m "Publish $NameRoot $($Data.ModuleVersion)"
            &git -C "$Path" tag "V$($Data.ModuleVersion)"
            &git -C "$Path" push 
            &git -C "$Path" push --tags
        }
        else {
            Write-Output "Git executable not found in PATH environment variable."
        }
    }
    catch {
        Write-Error "Failed to publish module: $($_.Exception.Message)"
    }

}

function PublishModule3 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cppm3")]   
    param(
        [string] $Path = ""
    )

    if ($Path -eq "")
    {
        $loc = Get-Location
        $Path = $loc.Path
    }

    $Path = $Path.TrimEnd('\')

    $LastDirectory = Split-Path -Path $Path -Leaf
    $psd1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" } | Select-Object BaseName
    $psm1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psm1" } | Select-Object BaseName

    if($psd1BaseName.Count -eq 0)
    {
        Write-Error "Error: no powerShell module manifest files found. Please ensure that there is one .psd1 file in the directory and try again."
        return
    }

    if($psm1BaseName.Count -eq 0)
    {
        Write-Error "Error: no root module files found. Please ensure that there is one .psm1 file in the directory and try again."
        return
    }

    if($psd1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psd1 file in the directory and try again."
        return
    }

    if($psm1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psm1 file in the directory and try again."
        return
    }

    if (-not($psd1BaseName.BaseName -eq $psm1BaseName.BaseName))
    {
        Write-Error "Error: .psd1 filename, and .psm1 filename must all be identical. Please ensure that these names match and try again."
        return
    }

    #update
    if (-not($LastDirectory -eq $psd1BaseName.BaseName))
    { 
        Write-Warning  "Warning: The publish path has not the name of the module. Copying source for publish to a temporary directory."
        $tempdir = New-TempDirectory
        $tempmoduledir = New-Directory -Directory "$tempdir\$($psd1BaseName.BaseName)"
        Copy-Recursive -Source "$Path" -Destination "$tempmoduledir"
        $PublishPath = $tempmoduledir
    }
    else {
        $PublishPath = $Path
    }

    $keyFileFullName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Name -eq ".key" } | Select-Object FullName
    if($null -eq $keyFileFullName)
    {
        Write-Error  "Error: A .key file containing the NuGet API key is missing from the publish directory. Please add the file and try again."
        return
    }

    $gitignoreFullName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Name -eq ".gitignore" } | Select-Object FullName
    if($null -eq $gitignoreFullName)
    {
        Write-Warning  "Warning: A .gitignore file is not present, the NuGet API key may be exposed in the publish directory. Please include a .gitignore file with ignore statements for the key to prevent unauthorized access."
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    #Initialize-PowerShellGetLatest
    #Initialize-PackageManagementLatest

    [string]$NuGetAPIKey = Get-Content -Path "$($keyFileFullName.FullName)"
    
    $fullname = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" }

    $fileContent = Get-Content -Path "$($fullname.FullName)" -Raw
    $index = $fileContent.IndexOf("@{")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }
    $index = $fileContent.LastIndexOf("}")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }

    $Data  = Invoke-Expression "[PSCustomObject]@{$fileContent}"

    try {
        
        Publish-Module -Path "$PublishPath" -NuGetApiKey "$NuGetAPIKey" -Repository "PSGallery" -Verbose

        $moduleName = Split-Path $MyInvocation.MyCommand.Module.Name -Leaf
        $moduleVersion = $MyInvocation.MyCommand.Module.Version
        Write-Output "Publish with $moduleName $moduleVersion."

        $executable = Get-Command "git" -ErrorAction SilentlyContinue
        
        [string]$NameRoot = $Data.RootModule
        $NameRoot = $NameRoot -replace '\.psm1$'

        if ($executable) {
            Write-Output "Git executable found at $($executable.Source) automatic git add -A, commit and push."
            &git -C "$Path" add -A
            &git -C "$Path" commit -m "Publish $NameRoot $($Data.ModuleVersion)"
            &git -C "$Path" tag "V$($Data.ModuleVersion)"
            &git -C "$Path" push 
            &git -C "$Path" push --tags
        }
        else {
            Write-Output "Git executable not found in PATH environment variable."
        }
    }
    catch {
        Write-Error "Failed to publish module: $($_.Exception.Message)"
    }
    finally {
        if (-not($LastDirectory -eq $psd1BaseName.BaseName))
        { 
            Remove-TempDirectory -TempDirectory $tempdir
            Write-Warning  "Removed temp directory $tempdir"
        }
    }

}


function PublishModule4 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cppm4")]   
    param(
        [string] $Path = ""
    )

    if ($Path -eq "")
    {
        $loc = Get-Location
        $Path = $loc.Path
    }

    $Path = $Path.TrimEnd('\')

    $LastDirectory = Split-Path -Path $Path -Leaf
    $psd1BaseName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Extension -eq ".psd1" }
    $psm1BaseName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Extension -eq ".psm1" }
    

    if($psd1BaseName.Count -eq 0)
    {
        Write-Error "Error: no powerShell module manifest files found. Please ensure that there is one .psd1 file in the directory and try again."
        return
    }

    if($psm1BaseName.Count -eq 0)
    {
        Write-Error "Error: no root module files found. Please ensure that there is one .psm1 file in the directory and try again."
        return
    }

    if($psd1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psd1 file in the directory and try again."
        return
    }

    if($psm1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psm1 file in the directory and try again."
        return
    }

    if (-not($psd1BaseName.BaseName -eq $psm1BaseName.BaseName))
    {
        Write-Error "Error: .psd1 filename, and .psm1 filename must all be identical. Please ensure that these names match and try again."
        return
    }

    #$pubdir1 =Split-Path -Path $psm1BaseName.DirectoryName -Leaf
    #$pubdir = $psm1BaseName.DirectoryName

    #update
    if (-not((Split-Path -Path $psm1BaseName.DirectoryName -Leaf) -eq $psd1BaseName.BaseName))
    { 
        Write-Warning  "Warning: The publish path has not the name of the module. Copying source for publish to a temporary directory."
        $tempdir = New-TempDirectory
        $tempmoduledir = New-Directory -Directory "$tempdir\$($psd1BaseName.BaseName)"
        Copy-Recursive -Source "$($psm1BaseName.DirectoryName)" -Destination "$tempmoduledir"
        $PublishPath = $tempmoduledir
    }
    else {
        $PublishPath = $psm1BaseName.DirectoryName
    }

    $keyFileFullName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Name -eq ".key" } | Select-Object FullName
    if($null -eq $keyFileFullName)
    {
        Write-Error  "Error: A .key file containing the NuGet API key is missing from the publish directory. Please add the file and try again."
        return
    }

    $gitignoreFullName = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Name -eq ".gitignore" } | Select-Object FullName
    if($null -eq $gitignoreFullName)
    {
        Write-Warning  "Warning: A .gitignore file is not present, the NuGet API key may be exposed in the publish directory. Please include a .gitignore file with ignore statements for the key to prevent unauthorized access."
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12



    [string]$NuGetAPIKey = Get-Content -Path "$($keyFileFullName.FullName)"
    
    $fullname = Get-ChildItem -Path "$PublishPath" | Where-Object { $_.Extension -eq ".psd1" }

    $fileContent = Get-Content -Path "$($fullname.FullName)" -Raw
    $index = $fileContent.IndexOf("@{")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }
    $index = $fileContent.LastIndexOf("}")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }

    $Data  = Invoke-Expression "[PSCustomObject]@{$fileContent}"

    try {
        
        #Initialize-PowerShellGetLatest
        #Initialize-PackageManagementLatest

        Publish-Module -Path "$PublishPath" -NuGetApiKey "$NuGetAPIKey" -Repository "PSGallery" -Verbose

        $moduleName = Split-Path $MyInvocation.MyCommand.Module.Name -Leaf
        $moduleVersion = $MyInvocation.MyCommand.Module.Version
        Write-Output "Publish with $moduleName $moduleVersion."

        $executable = Get-Command "git" -ErrorAction SilentlyContinue
        
        [string]$NameRoot = $Data.RootModule
        $NameRoot = $NameRoot -replace '\.psm1$'

        if ($executable) {
            Write-Output "Git executable found at $($executable.Source) automatic git add -A, commit and push."
            &git -C "$Path" add -A
            &git -C "$Path" commit -m "Publish $NameRoot $($Data.ModuleVersion)"
            &git -C "$Path" tag "V$($Data.ModuleVersion)"
            &git -C "$Path" push 
            &git -C "$Path" push --tags
        }
        else {
            Write-Output "Git executable not found in PATH environment variable."
        }
    }
    catch {
        Write-Error "Failed to publish module: $($_.Exception.Message)"
    }
    finally {
        if (-not((Split-Path -Path $psm1BaseName.DirectoryName -Leaf) -eq $psd1BaseName.BaseName))
        { 
            Remove-TempDirectory -TempDirectory $tempdir
            Write-Warning  "Removed temp directory $tempdir"
        }
    }

}

function PublishModule5 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cppm5")]   
    param(
        [string] $Location = ""
    )

    if ($Location -eq "")
    {
        $Location = Get-Location
        $Location = $Location.Path
    }

    $Location = $Location.TrimEnd([IO.Path]::DirectorySeparatorChar)

    $manifest = Read-Manifests -ManifestLocation "$Location"

    if (-not($manifest.Count -eq 1))
    {
        Write-Error "Error: None or Multiple PowerShell module manifest files found. Please ensure that there is one .psd1 file specified and try again."
        return
    }

    #update
    if (-not($manifest.Added_ContainingFolderPublish))
    { 
        Write-Warning  "Warning: The publish path has not the name of the module. Copying source for publish to a temporary directory."
        $tempdir = New-TempDirectory
        $tempmoduledir = New-Directory -Directory "$tempdir\$($manifest.PSD_BaseName)"
        Copy-Recursive -Source "$($manifest.Added_ContainingFolder)" -Destination "$tempmoduledir"
        $manifest.Added_ContainingFolder = $tempmoduledir
    }
   
    $keyFileFullName = Get-ChildItem -Path $manifest.Added_ContainingFolder -Recurse | Where-Object { $_.Name -eq ".key" } | Select-Object FullName
    if($null -eq $keyFileFullName)
    {
        Write-Error  "Error: A .key file containing the NuGet API key is missing from the publish directory. Please add the file and try again."
        return
    }

    $gitignoreFullName = Get-ChildItem -Path $manifest.Added_ContainingFolder -Recurse | Where-Object { $_.Name -eq ".gitignore" } | Select-Object FullName
    if($null -eq $gitignoreFullName)
    {
        Write-Warning  "Warning: A .gitignore file is not present, the NuGet API key may be exposed in the publish directory. Please include a .gitignore file with ignore statements for the key to prevent unauthorized access."
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    [string]$NuGetAPIKey = Get-Content -Path "$($keyFileFullName.FullName)"
    
      try {
        
        Publish-Module -Path "$($manifest.Added_ContainingFolder)" -NuGetApiKey "$NuGetAPIKey" -Repository "PSGallery" -Verbose

        $moduleName = Split-Path $MyInvocation.MyCommand.Module.Name -Leaf
        $moduleVersion = $MyInvocation.MyCommand.Module.Version
        Write-Output "Publish with $moduleName $moduleVersion."

        $executable = Get-Command "git" -ErrorAction SilentlyContinue
        
        if ($executable) {
            Write-Output "Git executable found at $($executable.Source) automatic git add -A, commit and push."
            &git -C "$($manifest.Added_ContainingFolder)" add -A
            &git -C "$($manifest.Added_ContainingFolder)" commit -m "Publish $($manifest.Added_PSD_BaseName) $($manifest.ModuleVersion)"
            &git -C "$($manifest.Added_ContainingFolder)" tag "V$($manifest.ModuleVersion)"
            &git -C "$($manifest.Added_ContainingFolder)" push 
            &git -C "$($manifest.Added_ContainingFolder)" push --tags
        }
        else {
            Write-Output "Git executable not found in PATH environment variable."
        }
    }
    catch {
        Write-Error "Failed to publish module: $($_.Exception.Message)"
    }
    finally {
        if (-not($manifest.Added_ContainingFolderPublish))
        { 
            Remove-TempDirectory -TempDirectory $tempdir
            Write-Warning  "Removed temp directory $tempdir"
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

function UpdateModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cpum")]
    param(
        [string] $Path = ""
    )

    if ($Path -eq "")
    {
        $loc = Get-Location
        $Path = $loc.Path
    }

    $Path = $Path.TrimEnd('\')

    $psd1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" } | Select-Object FullName

    if($psd1BaseName.Count -eq 0)
    {
        Write-Error "Error: no powerShell module manifest files found. Please ensure that there is one .psd1 file in the directory and try again."
        return
    }

    if($psd1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psd1 file in the directory and try again."
        return
    }

    $fileContent = Get-Content -Path "$($psd1BaseName.FullName)" -Raw
    $index = $fileContent.IndexOf("@{")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }
    $index = $fileContent.LastIndexOf("}")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }

    $Data  = Invoke-Expression "[PSCustomObject]@{$fileContent}"

    $ver = [Version]$Data.ModuleVersion
    $newver = [Version]::new($ver.Major, $ver.Minor, $ver.Build, ($ver.Revision + 1))
    $Data.ModuleVersion = [string]$newver
    $Data.PrivateData.PSData.LicenseUri = $Data.PrivateData.PSData.LicenseUri.Replace($ver, $newver)

    $psd1layoutx = [pscustomobject]@{
        RootModule = ''
        ModuleVersion = ''
        CompatiblePSEditions = @()
        GUID = ''
        Author = ''
        CompanyName = ''
        Copyright = ''
        Description = ''
        PowerShellVersion = ''
        PowerShellHostName = ''
        PowerShellHostVersion = ''
        DotNetFrameworkVersion = ''
        CLRVersion = ''
        ProcessorArchitecture = ''
        RequiredModules = @()
        RequiredAssemblies = @()
        ScriptsToProcess = @()
        TypesToProcess = @()
        FormatsToProcess = @()
        NestedModules = @()
        FunctionsToExport = @()
        CmdletsToExport = @()
        VariablesToExport = ''
        AliasesToExport = @()
        DscResourcesToExport = @()
        ModuleList = @()
        FileList = @()
        PrivateData = @{PSData = @{
                LicenseUri = ''
                Tags = ' '
                ProjectUri = ''
                IconUri = ''
                ReleaseNotes = ''
            }}
        HelpInfoURI = ''
        DefaultCommandPrefix = ''
    }

    # Merge the properties of the second object into the combined object
    Merge-Object $Data $psd1layoutx 

    if ("" -eq $Data.PrivateData.PSData.ReleaseNotes)
    {
        $fullswitch = "-ReleaseNotes `"$($Data.PrivateData.PSData.ReleaseNotes)`""
    }

    $fullswitch = ""

    New-ModuleManifest `
    -Path "$($psd1BaseName.FullName)" `
    -GUID "$($Data.GUID)" `
    -Description "$($Data.Description)" `
    -LicenseUri "$($Data.PrivateData.PSData.LicenseUri)" `
    -ProjectUri "$($Data.PrivateData.PSData.ProjectUri)" `
    -IconUri "$($Data.PrivateData.PSData.IconUri)" `
    $fullswitch `
    -FunctionsToExport $Data.FunctionsToExport `
    -AliasesToExport $Data.AliasesToExport  `
    -ModuleVersion "$($Data.ModuleVersion)" `
    -RootModule "$($Data.RootModule)" `
    -Author "$($Data.Author)" `
    -RequiredModules $Data.RequiredModules  `
    -CompanyName "$($Data.CompanyName)"  `
    -Tags $($Data.PrivateData.PSData.Tags) `
    -CmdletsToExport @($Data.CmdletsToExport) `
    -VariablesToExport @($Data.VariablesToExport) `
    -CompatiblePSEditions @($Data.CompatiblePSEditions)

    #(Get-Content -path "$Path\$ModuleName\$ModuleName.psd1") | Set-Content -Encoding default -Path "$Path\$ModuleName\$ModuleName.psd1"
    
}


#CreateModule -Path "C:\temp" -ModuleName "CoreePower.Module" -Description "Library for module management" -Author "Carsten Riedel"
function CreateModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cpcm")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Author,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
    )

    if ($Path -eq "")
    {
        $loc = Get-Location
        $Path = $loc.Path
    }

    $Path = $Path.TrimEnd('\')

    #$psd1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" } | Select-Object FullName

    # Check if the directory exists
    if(!(Test-Path $Path)){
        # Create the directory if it does not exist
        New-Item -ItemType Directory -Path $Path  | Out-Null
    }

    # Check if the directory exists
    if(!(Test-Path "$Path\$ModuleName")){
        # Create the directory if it does not exist
        New-Item -ItemType Directory -Path "$Path\$ModuleName" | Out-Null
    }

    $licenceValue  = @"
    MIT License

    Copyright (c) $((Get-Date).Year) $Author
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
"@

    $psm1Value  = @"
<#
    $ModuleName root module
#>

Import-Module -Name "Other.Module" -MinimumVersion "0.0.0.1"

. `"`$PSScriptRoot\$ModuleName.ps1`"

"@

    $ps1Value  = @"

function SampleFunction {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("sf")]
    param()
    Write-Output "Hello World!"
}

"@

    Set-Content -Path "$Path\$ModuleName\LICENSE.txt" -Value "$licenceValue"
    Set-Content -Path "$Path\$ModuleName\$ModuleName.psm1" -Value "$psm1Value"
    Set-Content -Path "$Path\$ModuleName\$ModuleName.ps1" -Value "$ps1Value"
    Set-Content -Path "$Path\$ModuleName\.key" -Value "$ApiKey"
    Set-Content -Path "$Path\$ModuleName\.gitignore" -Value ".key"
<#
    $psd1layout.Author = "$Author"
    $psd1layout.RootModule = "$ModuleName.psm1"
    $psd1layout.CompanyName = "$Author"
    $psd1layout.Copyright = "(c) 2023 $Author. All rights reserved."
    $psd1layout.Description = $Description
    $psd1layout.GUID = (New-Guid).ToString()
    $psd1layout.FunctionsToExport = @("SampleFunction")
    $psd1layout.AliasesToExport = @("sf")
    $psd1layout.ModuleVersion = "0.0.0.1"
    $psd1layout.RequiredModules = @(@{ ModuleName = 'Other.Module' ; ModuleVersion = '0.0.0.1' })
    $psd1layout.PrivateData.PSData.LicenseUri = "https://www.powershellgallery.com/packages/$ModuleName/0.0.0.1/Content/LICENSE.txt"
    $psd1layout.PrivateData.PSData.Tags = @("example","module")
#>
    New-ModuleManifest `
    -Path "$Path\$ModuleName\$ModuleName.psd1" `
    -GUID "$((New-Guid).ToString())" `
    -Description "$Description" `
    -LicenseUri "https://www.powershellgallery.com/packages/$ModuleName/0.0.0.1/Content/LICENSE.txt" `
    -FunctionsToExport @("SampleFunction") `
    -AliasesToExport @("sf")  `
    -ModuleVersion "0.0.0.1" `
    -RootModule "$ModuleName.psm1" `
    -Author "$Author" `
    -RequiredModules @(@{ ModuleName = 'Other.Module' ; ModuleVersion = '0.0.0.1' })  `
    -CompanyName "$Author" `
    -Tags @("empty","module")

    (Get-Content -path "$Path\$ModuleName\$ModuleName.psd1") | Set-Content -Encoding default -Path "$Path\$ModuleName\$ModuleName.psd1"

<#
    $towrite = ConvertToExpression -InputObject $psd1layout

    $towrite = $towrite -replace "^\[pscustomobject\]", ""

    if (-not($null -eq $towrite))
    {
        # Write the string to a file
        Set-Content -Path "$Path\$ModuleName\$ModuleName.psd1" -Value $towrite
    }
    #>
}

function CreateModule2 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cpcm2")]
    param(
        [string]$Path = "",
        [string]$Nested = "",
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Author,
        [string]$ApiKey = ""
    )

    if ($Path -eq "")
    {
        $loc = Get-Location
        $Path = $loc.Path
    }

    if ($Nested -ne "")
    {
        $Nested = ([IO.Path]::DirectorySeparatorChar + $Nested).TrimEnd([IO.Path]::DirectorySeparatorChar)
    }

    if ($ApiKey -eq "")
    {
        Write-Warning "Error: In order to use PublishModule a nuget api key should be present in. ""$Path\$ModuleName$Nested\.key"""
    }

    $Path = $Path.TrimEnd('\')

    #$psd1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" } | Select-Object FullName

    # Check if the directory exists
    if(!(Test-Path $Path)){
        # Create the directory if it does not exist
        New-Item -ItemType Directory -Path $Path  | Out-Null
    }

    # Check if the directory exists
    if(!(Test-Path "$Path\$ModuleName$Nested")){
        # Create the directory if it does not exist
        New-Item -ItemType Directory -Path "$Path\$ModuleName$Nested" | Out-Null
    }

    $licenceValue  = @"
    MIT License

    Copyright (c) $((Get-Date).Year) $Author
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
"@

    $psm1Value  = @"
<#
    $ModuleName root module
#>

# Add other depended modules here, you need to add them in the psd1 file as
# RequiredModules = @(@{ModuleName = 'Other.Module'; ModuleVersion = '0.0.0.30'; })
# The ModuleVersion is the minimum required version

#Import-Module -Name "Other.Module" -MinimumVersion "0.0.0.1"

. `"`$PSScriptRoot\$ModuleName.ps1`"

"@

    $ps1Value  = @"

function SampleFunction {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("sf")]
    param()
    Write-Output "Hello World!"
}

"@

    Set-Content -Path "$Path\$ModuleName$Nested\LICENSE.txt" -Value "$licenceValue"
    Set-Content -Path "$Path\$ModuleName$Nested\$ModuleName.psm1" -Value "$psm1Value"
    Set-Content -Path "$Path\$ModuleName$Nested\$ModuleName.ps1" -Value "$ps1Value"
    Set-Content -Path "$Path\$ModuleName$Nested\.key" -Value "$ApiKey"
    Set-Content -Path "$Path\$ModuleName$Nested\.gitignore" -Value ".key"
<#
    $psd1layout.Author = "$Author"
    $psd1layout.RootModule = "$ModuleName.psm1"
    $psd1layout.CompanyName = "$Author"
    $psd1layout.Copyright = "(c) 2023 $Author. All rights reserved."
    $psd1layout.Description = $Description
    $psd1layout.GUID = (New-Guid).ToString()
    $psd1layout.FunctionsToExport = @("SampleFunction")
    $psd1layout.AliasesToExport = @("sf")
    $psd1layout.ModuleVersion = "0.0.0.1"
    $psd1layout.RequiredModules = @(@{ ModuleName = 'Other.Module' ; ModuleVersion = '0.0.0.1' })
    $psd1layout.PrivateData.PSData.LicenseUri = "https://www.powershellgallery.com/packages/$ModuleName/0.0.0.1/Content/LICENSE.txt"
    $psd1layout.PrivateData.PSData.Tags = @("example","module")
#>
    New-ModuleManifest `
    -Path "$Path\$ModuleName$Nested\$ModuleName.psd1" `
    -GUID "$((New-Guid).ToString())" `
    -Description "$Description" `
    -LicenseUri "https://www.powershellgallery.com/packages/$ModuleName/0.0.0.1/Content/LICENSE.txt" `
    -FunctionsToExport @("SampleFunction") `
    -AliasesToExport @("sf")  `
    -ModuleVersion "0.0.0.1" `
    -RootModule "$ModuleName.psm1" `
    -Author "$Author" `
    -CompanyName "$Author" `
    -Tags @("empty","module")

    (Get-Content -path "$Path\$ModuleName$Nested\$ModuleName.psd1") | Set-Content -Encoding default -Path "$Path\$ModuleName$Nested\$ModuleName.psd1"

<#
    $towrite = ConvertToExpression -InputObject $psd1layout

    $towrite = $towrite -replace "^\[pscustomobject\]", ""

    if (-not($null -eq $towrite))
    {
        # Write the string to a file
        Set-Content -Path "$Path\$ModuleName\$ModuleName.psd1" -Value $towrite
    }
    #>
}

function CreateModule3 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cpcm3")]
    param(
        [string]$Path = "",
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Author,
        [string]$ApiKey = ""
    )

    if ($Path -eq "")
    {
        $loc = Get-Location
        $Path = $loc.Path
    }

    if ($Nested -ne "")
    {
        $Nested = ([IO.Path]::DirectorySeparatorChar + $Nested).TrimEnd([IO.Path]::DirectorySeparatorChar)
    }

    if ($ApiKey -eq "")
    {
        Write-Warning "Error: In order to use PublishModule a nuget api key should be present in. ""$Path\$ModuleName\src\.key"""
    }

    $Path = $Path.TrimEnd('\')

    #$psd1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" } | Select-Object FullName

    # Check if the directory exists
    if(!(Test-Path $Path)){
        # Create the directory if it does not exist
        New-Item -ItemType Directory -Path $Path  | Out-Null
    }

    # Check if the directory exists
    if(!(Test-Path "$Path\$ModuleName\src")){
        # Create the directory if it does not exist
        New-Item -ItemType Directory -Path "$Path\$ModuleName\src" | Out-Null
    }

    $licenceValue  = @"
    MIT License

    Copyright (c) $((Get-Date).Year) $Author
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
"@

    $psm1Value  = @"
<#
    $ModuleName root module
#>

# Add other depended modules here, you need to add them in the psd1 file as
# RequiredModules = @(@{ModuleName = 'Other.Module'; ModuleVersion = '0.0.0.30'; })
# The ModuleVersion is the minimum required version

#Import-Module -Name "Other.Module" -MinimumVersion "0.0.0.1"

. `"`$PSScriptRoot\$ModuleName.ps1`"

"@

    $ps1Value  = @"

function SampleFunction {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("sf")]
    param()
    Write-Output "Hello World!"
}

"@

    $testrunner = @"

    Write-Host "RunnerImports: `$(`$MyInvocation.MyCommand.Source) called in Mode: `$Mode"

    `$parent = (Get-Item ([System.IO.Path]::GetDirectoryName(`$MyInvocation.MyCommand.Path))).Parent
    `$import = `$parent.FullName +"\src\`$(`$parent.Name).`$(`$Mode)1"

    `$reqmods = (ReadModulePsd -SearchRoot "`$import").RequiredModules

    foreach (`$item in `$reqmods)
    {
        `$module = Get-Module -ListAvailable -Name `$item.ModuleName | Sort-Object Version -Descending | Select-Object -First 1
        if (`$module) {
            if (`$module.Version -ge `$item.ModuleVersion) {
                Write-Host "The module is available and meets the minimum version requirement."
            } else {
                Install-Module -Name "`$(`$item.ModuleName)" -Force
            }
        } else {
            Install-Module -Name "`$(`$item.ModuleName)" -Force
        }
    }

    Import-Module "`$import" -Force -Verbose
    Write-Host "Imported Module: `$import"

    . "`$PSScriptRoot\RunnerTests.ps1"
    Write-Host "Dot sourced tests: `$(`$PSScriptRoot)\RunnerTests.ps1"

    `$retvals = @()
    `$retval = `$false

    #Add addtional test functions here
    `$functionName = "Test-SampleFunction"; `$retval = & `$functionName;if (`$retval -is [array]) { `$retval = `$retval[-1] }; `$retvals += @{ FunctionName = `$functionName; Result = `$retval };

    `$allSucceeded = `$true

    # Iterate over the `$retvals array and show results
    `$retvals | ForEach-Object {
        if (`$_.Result) {
            Write-Output "`$(`$_.FunctionName) succeeded."
        } else {
            Write-Output "`$(`$_.FunctionName) failed."
            `$allSucceeded = `$false
        }
    }

    if (`$allSucceeded)
    {
        Write-Output "allSucceeded."
    }

"@

    $testrunnerfunc = @"
    function Test-SampleFunction {
        param()
        [bool]`$retval = `$false;
        SampleFunction
        [bool]`$retval = `$true
        return `$retval
    }
"@

    New-Item -ItemType Directory -Path "$Path\$ModuleName\src" -Force | Out-Null
    New-Item -ItemType Directory -Path "$Path\$ModuleName\test" -Force | Out-Null
    New-Item -ItemType Directory -Path "$Path\$ModuleName\res" -Force | Out-Null

    Set-Content -Path "$Path\$ModuleName\test\RunnerImport.ps1" -Value "$testrunner"
    Set-Content -Path "$Path\$ModuleName\test\RunnerTests.ps1" -Value "$testrunnerfunc"

    Set-Content -Path "$Path\$ModuleName\src\LICENSE.txt" -Value "$licenceValue"
    Set-Content -Path "$Path\$ModuleName\src\$ModuleName.psm1" -Value "$psm1Value"
    Set-Content -Path "$Path\$ModuleName\src\$ModuleName.ps1" -Value "$ps1Value"
    Set-Content -Path "$Path\$ModuleName\src\.key" -Value "$ApiKey"
    Set-Content -Path "$Path\$ModuleName\src\.gitignore" -Value ".key"


    New-ModuleManifest `
    -Path "$Path\$ModuleName\src\$ModuleName.psd1" `
    -GUID "$((New-Guid).ToString())" `
    -Description "$Description" `
    -LicenseUri "https://www.powershellgallery.com/packages/$ModuleName/0.0.0.1/Content/LICENSE.txt" `
    -FunctionsToExport @("SampleFunction") `
    -AliasesToExport @("sf")  `
    -ModuleVersion "0.0.0.1" `
    -RootModule "$ModuleName.psm1" `
    -Author "$Author" `
    -CompanyName "$Author" `
    -Tags @("empty","module")

    (Get-Content -path "$Path\$ModuleName\src\$ModuleName.psd1") | Set-Content -Encoding default -Path "$Path\$ModuleName\src\$ModuleName.psd1"

}

#CreateModule -Path "C:\temp" -ModuleName "CoreePower.Module" -Description "Library for module management" -Author "Carsten Riedel" 
#UpdateModuleVersion -Path "C:\temp\CoreePower.Module"

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

function UpdateModule2 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cpum2")]
    param(
        [string] $Path = ""
    )

    if ($Path -eq "")
    {
        $loc = Get-Location
        $Path = $loc.Path
    }

    $Path = $Path.TrimEnd('\')

    $psd1BaseName = Get-ChildItem -Path $Path | Where-Object { $_.Extension -eq ".psd1" } | Select-Object FullName

    if($psd1BaseName.Count -eq 0)
    {
        Write-Error "Error: no powerShell module manifest files found. Please ensure that there is one .psd1 file in the directory and try again."
        return
    }

    if($psd1BaseName.Count -gt 1)
    {
        Write-Error "Error: multiple module definition files found. Please ensure that there is only one .psd1 file in the directory and try again."
        return
    }

    $fileContent = Get-Content -Path "$($psd1BaseName.FullName)" -Raw
    $index = $fileContent.IndexOf("@{")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }
    $index = $fileContent.LastIndexOf("}")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }

    $Data  = Invoke-Expression "[PSCustomObject]@{$fileContent}"

    $ver = [Version]$Data.ModuleVersion
    $newver = [Version]::new($ver.Major, $ver.Minor, $ver.Build, ($ver.Revision + 1))
    $Data.ModuleVersion = [string]$newver
    $Data.PrivateData.PSData.LicenseUri = $Data.PrivateData.PSData.LicenseUri.Replace($ver, $newver)

    $params = @{
        Path = "$($psd1BaseName.FullName)"
        RootModule = "$($Data.RootModule)"
        ModuleVersion = "$($Data.ModuleVersion)"
        GUID = "$($Data.GUID)"
        Description = "$($Data.Description)"
        Author = "$($Data.Author)"
    }

    if ($Data.FunctionsToExport) {
        $params["FunctionsToExport"] = $Data.FunctionsToExport
    }

    if ($Data.AliasesToExport) {
        $params["AliasesToExport"] = $Data.AliasesToExport
    }

    if ($Data.VariablesToExport) {
        $params["VariablesToExport"] = $Data.VariablesToExport
    }

    if ($Data.CmdletsToExport) {
        $params["CmdletsToExport"] = $Data.CmdletsToExport
    }

    if ($Data.RequiredModules) {
        $params["RequiredModules"] = $Data.RequiredModules
    }

    if ($Data.CompanyName) {
        $params["CompanyName"] = $Data.CompanyName
    }

    if ($Data.CompatiblePSEditions) {
        $params["CompatiblePSEditions"] = $Data.CompatiblePSEditions
    }

    if ($Data.PrivateData.PSData.Tags) {
        $params["Tags"] = $($Data.PrivateData.PSData.Tags)
    }

    if ($Data.PrivateData.PSData.ReleaseNotes) {
        $params["ReleaseNotes"] = "$($Data.PrivateData.PSData.ReleaseNotes)"
    }

    if ($Data.PrivateData.PSData.LicenseUri) {
        $params["LicenseUri"] = "$($Data.PrivateData.PSData.LicenseUri)"
    }

    if ($Data.PrivateData.PSData.IconUri) {
        $params["IconUri"] = "$($Data.PrivateData.PSData.IconUri)"
    }

    if ($Data.PrivateData.PSData.ProjectUri) {
        $params["ProjectUri"] = "$($Data.PrivateData.PSData.ProjectUri)"
    }

    # Wildcard fixes
    if (-not($params["CmdletsToExport"]))
    {
        $params["CmdletsToExport"] = ""
    }

    if (-not($params["VariablesToExport"]))
    {
        $params["VariablesToExport"] = ""
    }
    

    New-ModuleManifest @params
    
}



function UpdateModule3 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cpum3")]
    param(
        [string] $SearchRoot = ""
    )

    #SearchRoot is current directory if not used
    if ($SearchRoot -eq "")
    {
        $loc = Get-Location
        $SearchRoot = $loc.Path
    }

    #Fix end of string if backslash is supplied
    $SearchRoot = $SearchRoot.TrimEnd([IO.Path]::DirectorySeparatorChar)

    $PowerShellModuleManifest = Get-ChildItem -Path $SearchRoot -Recurse | Where-Object { $_.Extension -eq ".psd1" }

    if($PowerShellModuleManifest.Count -eq 0)
    {
        Write-Error "Error: No PowerShell module manifest files found. Please ensure that there is one .psd1 file in the directory and try again."
        return
    }

    if($PowerShellModuleManifest.Count -gt 1)
    {
        Write-Error "Error: Multiple module manifest files found. Please ensure that there is only one .psd1 file in the directory and try again."
        return
    }

    $fileContent = Get-Content -Path "$($PowerShellModuleManifest.FullName)" -Raw
    $index = $fileContent.IndexOf("@{")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }
    $index = $fileContent.LastIndexOf("}")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }

    $Data  = Invoke-Expression "[PSCustomObject]@{$fileContent}"

    $PowerShellModuleManifestRootModule = $PowerShellModuleManifest.DirectoryName + [IO.Path]::DirectorySeparatorChar + $Data.RootModule

    if (-not(Test-Path -Path $PowerShellModuleManifestRootModule -PathType Leaf))
    {
        Write-Error "Error: Root module not found. $PowerShellModuleManifestRootModule"
        return
    }

    $ver = [Version]$Data.ModuleVersion
    $newver = [Version]::new($ver.Major, $ver.Minor, $ver.Build, ($ver.Revision + 1))
    $Data.ModuleVersion = [string]$newver
    $Data.PrivateData.PSData.LicenseUri = $Data.PrivateData.PSData.LicenseUri.Replace($ver, $newver)

    $params = @{
        Path = "$($PowerShellModuleManifest.FullName)"
        RootModule = "$($Data.RootModule)"
        ModuleVersion = "$($Data.ModuleVersion)"
        GUID = "$($Data.GUID)"
        Description = "$($Data.Description)"
        Author = "$($Data.Author)"
    }

    if ($Data.PowerShellVersion) {
        $params["PowerShellVersion"] = $Data.PowerShellVersion
    }

    if ($Data.PowerShellHostName) {
        $params["PowerShellHostName"] = $Data.PowerShellHostName
    }
    
    if ($Data.PowerShellHostVersion) {
        $params["PowerShellHostVersion"] = $Data.PowerShellHostVersion
    }

    if ($Data.FunctionsToExport) {
        $params["FunctionsToExport"] = $Data.FunctionsToExport
    }

    if ($Data.AliasesToExport) {
        $params["AliasesToExport"] = $Data.AliasesToExport
    }

    if ($Data.VariablesToExport) {
        $params["VariablesToExport"] = $Data.VariablesToExport
    }

    if ($Data.CmdletsToExport) {
        $params["CmdletsToExport"] = $Data.CmdletsToExport
    }

    if ($Data.RequiredModules) {
        $params["RequiredModules"] = $Data.RequiredModules
    }

    if ($Data.CompanyName) {
        $params["CompanyName"] = $Data.CompanyName
    }

    if ($Data.CompatiblePSEditions) {
        $params["CompatiblePSEditions"] = $Data.CompatiblePSEditions
    }

    if ($Data.PrivateData.PSData.Tags) {
        $params["Tags"] = $($Data.PrivateData.PSData.Tags)
    }

    if ($Data.PrivateData.PSData.ReleaseNotes) {
        $params["ReleaseNotes"] = "$($Data.PrivateData.PSData.ReleaseNotes)"
    }

    if ($Data.PrivateData.PSData.LicenseUri) {
        $params["LicenseUri"] = "$($Data.PrivateData.PSData.LicenseUri)"
    }

    if ($Data.PrivateData.PSData.IconUri) {
        $params["IconUri"] = "$($Data.PrivateData.PSData.IconUri)"
    }

    if ($Data.PrivateData.PSData.ProjectUri) {
        $params["ProjectUri"] = "$($Data.PrivateData.PSData.ProjectUri)"
    }

    # Wildcard fixes
    if (-not($params["CmdletsToExport"]))
    {
        $params["CmdletsToExport"] = ""
    }

    if (-not($params["VariablesToExport"]))
    {
        $params["VariablesToExport"] = ""
    }

    New-ModuleManifest @params
    
    Write-Warning "$($PowerShellModuleManifest.FullName) version is set to $($Data.ModuleVersion)"
}

function UpdateModule4 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cpum4")]
    param(
        [string] $Location = ""
    )

    if ($Location -eq "")
    {
        $Location = Get-Location
    }

    $Location = $Location.TrimEnd([IO.Path]::DirectorySeparatorChar)
    
    $manifest = @(Read-Manifests -ManifestLocation "$Location")

    if ($manifest.Length -ne 1)
    {
        Write-Error "Error: None or Multiple PowerShell module manifest files found. Please ensure that there is one .psd1 file specified and try again."
        return
    }
    else{
        $manifest = $manifest[0]
    }

    if (-not(Test-Path -Path $manifest.Added_RootModule_FullName -PathType Leaf))
    {
        Write-Error "Error: Root module not found. $($manifest.Added_RootModule_FullName)"
        return
    }

    $ver = [Version]$manifest.ModuleVersion
    $newver = [Version]::new($ver.Major, $ver.Minor, $ver.Build, ($ver.Revision + 1))
    $manifest.ModuleVersion = [string]$newver
    $manifest.PrivateData.PSData.LicenseUri = $manifest.PrivateData.PSData.LicenseUri.Replace($ver, $newver)

    $params = @{
        Path = "$($manifest.Added_PSD_FullName)"
        RootModule = "$($manifest.RootModule)"
        ModuleVersion = "$($manifest.ModuleVersion)"
        GUID = "$($manifest.GUID)"
        Description = "$($manifest.Description)"
        Author = "$($manifest.Author)"
    }

    if ($manifest.PowerShellVersion) {
        $params["PowerShellVersion"] = $manifest.PowerShellVersion
    }

    if ($manifest.PowerShellHostName) {
        $params["PowerShellHostName"] = $manifest.PowerShellHostName
    }
    
    if ($manifest.PowerShellHostVersion) {
        $params["PowerShellHostVersion"] = $manifest.PowerShellHostVersion
    }

    if ($manifest.FunctionsToExport) {
        $params["FunctionsToExport"] = $manifest.FunctionsToExport
    }

    if ($manifest.AliasesToExport) {
        $params["AliasesToExport"] = $manifest.AliasesToExport
    }

    if ($manifest.VariablesToExport) {
        $params["VariablesToExport"] = $manifest.VariablesToExport
    }

    if ($manifest.CmdletsToExport) {
        $params["CmdletsToExport"] = $manifest.CmdletsToExport
    }

    if ($manifest.RequiredModules) {
        $params["RequiredModules"] = $manifest.RequiredModules
    }

    if ($manifest.CompanyName) {
        $params["CompanyName"] = $manifest.CompanyName
    }

    if ($manifest.CompatiblePSEditions) {
        $params["CompatiblePSEditions"] = $manifest.CompatiblePSEditions
    }

    if ($manifest.PrivateData.PSData.Tags) {
        $params["Tags"] = $($manifest.PrivateData.PSData.Tags)
    }

    if ($manifest.PrivateData.PSData.ReleaseNotes) {
        $params["ReleaseNotes"] = "$($manifest.PrivateData.PSData.ReleaseNotes)"
    }

    if ($manifest.PrivateData.PSData.LicenseUri) {
        $params["LicenseUri"] = "$($manifest.PrivateData.PSData.LicenseUri)"
    }

    if ($manifest.PrivateData.PSData.IconUri) {
        $params["IconUri"] = "$($manifest.PrivateData.PSData.IconUri)"
    }

    if ($manifest.PrivateData.PSData.ProjectUri) {
        $params["ProjectUri"] = "$($manifest.PrivateData.PSData.ProjectUri)"
    }

    # Wildcard fixes
    if (-not($params["CmdletsToExport"]))
    {
        $params["CmdletsToExport"] = ""
    }

    if (-not($params["VariablesToExport"]))
    {
        $params["VariablesToExport"] = ""
    }

    New-ModuleManifest @params

    (Get-Content -path "$($manifest.Added_PSD_FullName)") | Set-Content -Encoding default -Path "$($manifest.Added_PSD_FullName)"
    
    Write-Warning "$($manifest.Added_PSD_FullName) version is set to $($manifest.ModuleVersion)"
}


function ReadModulePsd {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("rmpsd")]
    param(
        [string] $SearchRoot = ""
    )

    if (Test-Path $SearchRoot -PathType Leaf) {
        $dir = [IO.Path]::GetDirectoryName($SearchRoot)
        $PowerShellModuleManifest = Get-ChildItem -Path $dir -Recurse | Where-Object { $_.Extension -eq ".psd1" }
    } else {
        #SearchRoot is current directory if not used
        if ($SearchRoot -eq "")
        {
            $loc = Get-Location
            $SearchRoot = $loc.Path
        }

        #Fix end of string if backslash is supplied
        $SearchRoot = $SearchRoot.TrimEnd([IO.Path]::DirectorySeparatorChar)

        $PowerShellModuleManifest = Get-ChildItem -Path $SearchRoot -Recurse | Where-Object { $_.Extension -eq ".psd1" }
    }



    if($PowerShellModuleManifest.Count -eq 0)
    {
        Write-Error "Error: No PowerShell module manifest files found. Please ensure that there is one .psd1 file in the directory and try again."
        return
    }

    if($PowerShellModuleManifest.Count -gt 1)
    {
        Write-Error "Error: Multiple module manifest files found. Please ensure that there is only one .psd1 file in the directory and try again."
        return
    }

    $fileContent = Get-Content -Path "$($PowerShellModuleManifest.FullName)" -Raw
    $index = $fileContent.IndexOf("@{")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }
    $index = $fileContent.LastIndexOf("}")
    if($index -ne -1){
        $fileContent = $fileContent.Substring(0, $index) + $fileContent.Substring($index + 2)
    }

    $Data  = Invoke-Expression "[PSCustomObject]@{$fileContent}"

    return $Data
}
