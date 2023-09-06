function UpdateModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cpum")]
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
    $newver = [Version]::new($ver.Major, $ver.Minor, ($ver.Build+1),0)
    $manifest.ModuleVersion = "$($ver.Major).$($ver.Minor).$($ver.Build+1)"
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

    if ($manifest.PrivateData.PSData.Prerelease) {
        $params["Prerelease"] = "$($manifest.PrivateData.PSData.Prerelease)"
    }

    if ($manifest.PrivateData.PSData.RequireLicenseAcceptance) {
        $params["RequireLicenseAcceptance"] = "$($manifest.PrivateData.PSData.RequireLicenseAcceptance)"
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

