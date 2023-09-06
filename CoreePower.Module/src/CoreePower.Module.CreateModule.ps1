#CreateModule -ModuleName "CoreePower.Dev" -Description "Library for module management" -Author "Carsten Riedel"
function CreateModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cpcm")]
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

    Write-Host "RunnerImports: `$(`$MyInvocation.MyCommand.Source) called."
    `$ParentFolder = ((Get-Item ((Get-Item `$MyInvocation.MyCommand.Source).DirectoryName)).Parent).FullName
    `$ParentFolderContainingManifest = Read-Manifests -ManifestLocation "`$ParentFolder"
    `$reqmods = (`$ParentFolderContainingManifest).RequiredModules

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

    Import-Module "`$(`$ParentFolderContainingManifest.Added_RootModule_FullName)" -Force
    Write-Host "Imported Module: `$import"

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
    -LicenseUri "https://www.powershellgallery.com/packages/$ModuleName/0.0.1/Content/LICENSE.txt" `
    -FunctionsToExport @("SampleFunction") `
    -AliasesToExport @("sf")  `
    -ModuleVersion "0.0.1" `
    -RootModule "$ModuleName.psm1" `
    -Author "$Author" `
    -CompanyName "$Author" `
    -Tags @("empty","module")

    (Get-Content -path "$Path\$ModuleName\src\$ModuleName.psd1") | Set-Content -Encoding default -Path "$Path\$ModuleName\src\$ModuleName.psd1"

}
