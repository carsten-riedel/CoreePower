




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
