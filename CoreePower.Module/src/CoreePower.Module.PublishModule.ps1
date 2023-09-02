function PublishModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cppm")]   
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
        
        #copy recursive to temp dir
        $tempdir = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Temp' | Join-Path -ChildPath ([System.Guid]::NewGuid().ToString())
        if (-not (Test-Path $$tempdir)) {
            New-Item -ItemType Directory -Path $tempdir -Force | Out-Null
        }

        $tempmoduledir = "$tempdir\$($manifest.Added_PSD_BaseName)"
        New-Item -ItemType Directory -Path "$tempmoduledir" -Force | Out-Null

        Get-ChildItem "$($manifest.Added_ContainingFolder)" -Recurse | Foreach-Object {
            $targetPath = $_.FullName -replace [regex]::Escape("$($manifest.Added_ContainingFolder)"), $Destination
            if ($_.PSIsContainer) {
                New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
            }
            else {
                Copy-Item $_.FullName -Destination $targetPath -Force | Out-Null
            }
        }


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
            if (Test-Path -Path $tempdir -PathType Container) {
                Remove-Item -Path "$tempdir" -Recurse -Force
            }
        
            if (Test-Path -Path $tempdir -PathType Leaf) {
                $tempdir = [System.IO.Path]::GetDirectoryName($tempdir)
                $guidPattern = "\\[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
                if ($tempdir -match $guidPattern) {
                    # Removing parent directory recursively if it is a guid pattern
                    Remove-Item -Path "$tempdir" -Recurse -Force
                }
            }
            Write-Warning  "Removed temp directory $tempdir"
        }
    }

}