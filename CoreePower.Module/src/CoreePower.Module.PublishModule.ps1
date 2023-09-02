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

    $PublishFolder = $manifest.Added_ContainingFolder
    #update
    if (-not($manifest.Added_ContainingFolderPublish))
    { 
        Write-Warning  "Warning: The publish path has not the name of the module. Copying source for publish to a temporary directory."
        $tempdir = New-TempDirectory
        $tempmoduledir = New-Directory -Directory "$tempdir\$($manifest.Added_PSD_BaseName)"
        Copy-Recursive -Source "$($manifest.Added_ContainingFolder)" -Destination "$tempmoduledir"
        $PublishFolder = $tempmoduledir
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
        
        Publish-Module -Path "$PublishFolder" -NuGetApiKey "$NuGetAPIKey" -Repository "PSGallery" -Verbose

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