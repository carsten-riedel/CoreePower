# CoreePower.Config

## First install & update CoreePower Powershell Modules

This PowerShell command is designed to install CoreePower PowerShell modules on a fresh Windows install. It first checks if the NuGet package provider and PowerShellGet package management are outdated, and if so, silently installs the required updates. The command then checks the PowerShell Gallery for the specified packages listed in the $Install parameter and installs and imports them if they are not already installed or have a newer version available. By running this command, users can quickly and easily install the necessary PowerShell modules to enhance their command line experience. To use the command, simply copy and paste it into your PowerShell terminal.

```
$Install=@('PowerShellGet', 'CoreePower.*') ; try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge "2.8.5.201")) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null } ; Find-Module -Name $Install -Repository PSGallery | Select-Object Name,Version | Where-Object { -not (Get-Module -ListAvailable -Name $_.Name | Sort-Object Version -Descending | Select-Object -First 1 | Where-Object Version -eq $_.Version) } | ForEach-Object {  Install-Module -Name $_.Name -RequiredVersion $_.Version -Scope CurrentUser -Force -AllowClobber ; Import-Module -Name $_.Name -MinimumVersion $_.Version  }
```

Of course you can use the standard command.
```
Install-Module -Name CoreePower.Config
Install-Module -Name CoreePower.Module
```

## Managing CoreePower Modules with CoreePower.Module Command

The CoreePower.Module includes a convenient command to install and update all CoreePower modules while also removing old versions to keep the system clean. The command can be accessed using the alias "cpcp" To quickly list all available commands, you can use the " cplm -Name CoreePower.* " command. Stay up-to-date with the latest CoreePower modules by utilizing these helpful features.

```
cpcp
cplm -Name CoreePower.*
```

## Commands

### Command: CreateModule -Path "$Path" 
### Alias:   cpcm -Path "$Path"

#### Example
```
CreateModule -Path "C:\MyModules" -ModuleName "MyNewModule" -Description "This is my new PowerShell module" -Author "John Doe" -ApiKey "my-api-key"
```
The CreateModule function creates a PowerShell module with the specified parameters. If the path or the module directory does not exist, the function creates them. The function creates a LICENSE.txt file, a .psm1 module file, a .ps1 script file, and a .gitignore file. It also creates a module manifest (.psd1) file with the specified module details such as GUID, description, license URI, version, author, required modules, company name, and tags. The module manifest file is written to the module directory. This function is useful for creating new PowerShell modules quickly and efficiently.

Function parameters:

-Path: Specifies the path where the module directory will be created. If not specified, the current directory location will be used.

-ModuleName: Specifies the name of the module to be created.

-Description: Specifies a brief description of the module.

-Author: Specifies the name of the author of the module.

-ApiKey: Specifies the API key to be used for publishing the module to a repository. This is a mandatory parameter.

### Command: PublishModule -Path "$Path" 
### Alias:   cppm -Path "$Path"

#### Example
```
PublishModule -Path "C:\MyModules\MyNewModule"
```

This function publishes a PowerShell module to the PowerShell Gallery using the Publish-Module cmdlet, after performing validation checks to ensure that the module directory contains only one .psd1 and one .psm1 file, that the parent directory name, .psd1 filename, and .psm1 filename are all identical, and that a .key file containing the NuGet API key is present in the module directory. If any validation check fails, the function displays an error or warning message and returns without publishing the module.

Function parameters:

-Path: The path to the directory containing the PowerShell module to be published. This parameter is mandatory and must be provided as a string.

### Command: UpdateModule -Path "$Path" 
### Alias:   cpum -Path "$Path"

#### Example
```
UpdateModule -Path "C:\MyModules\MyNewModule"
```

The UpdateModule function first checks for a module manifest file (.psd1) in the specified directory. If no manifest file is found, or if multiple manifest files are found, an error message is displayed and the function exits. The function then updates the module version number and other details in the manifest file, such as the license URI, author, description, and required modules. Finally, the function updates the manifest file with the new version number and other changes using the New-ModuleManifest cmdlet.

**Note: The UpdateModule function supports most of the basic parameters of the New-ModuleManifest cmdlet, including GUID, Description, LicenseUri, FunctionsToExport, AliasesToExport, ModuleVersion, RootModule, Author, RequiredModules, CompanyName, and Tags. However, some less common parameters may not be supported, and if any of these parameters are included in the original module manifest file, their values may be lost during the update process. Therefore, it is recommended to use this function with caution and review the updated module manifest file to ensure that all required information is still present**

Function parameters:

-Path: Specifies the path of the module directory to update. If not specified, the current directory location will be used.

## Summery
The CreateModule, UpdateModule, and PublishModule functions work together to simplify the process of creating, updating, and publishing PowerShell modules to a gallery.

The CreateModule function creates a basic module structure with a root module, a PowerShell script, and a module manifest file, along with a license and a .gitignore file.

The UpdateModule function updates the version number and other details in the module manifest file, including required modules and dependencies.

Finally, the PublishModule function publishes the module to the PowerShell Gallery, prompting for a confirmation before publishing.

**The functions work quite well in Visual Studio Code, as the UpdateModule and PublishModule functions will automatically resolve the current directory, allowing them to be executed simply by typing cpum and cppm respectively.**

Together, these functions provide a streamlined workflow for creating and updating PowerShell modules, allowing developers to focus on writing code and reducing the time and effort required for managing module versions and dependencies.
