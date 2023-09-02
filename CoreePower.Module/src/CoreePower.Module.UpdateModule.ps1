
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

    #required for windows powershell direct publishing
    (Get-Content -path "$($manifest.Added_PSD_FullName)") | Set-Content -Encoding default -Path "$($manifest.Added_PSD_FullName)"
    
    Write-Warning "$($manifest.Added_PSD_FullName) version is set to $($manifest.ModuleVersion)"
}
