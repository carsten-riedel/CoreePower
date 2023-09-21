<#
.SYNOPSIS
    Reads assembly information from all DLL files within a specified directory.

.DESCRIPTION
    This function traverses a given directory (and its sub-directories) to identify all DLL files.
    For each DLL, it retrieves the assembly name and version and stores this information in a list.

.PARAMETER TargetDirectory
    Specifies the directory to search for DLL files.
    This is a mandatory parameter and should be a string representing the path to the directory.

.EXAMPLE
    Read-DirectoryAssembliesInfo -TargetDirectory "C:\MyDirectory"
    Scans "C:\MyDirectory" and its sub-directories for DLL files and returns assembly information for each one.

.LINK
    For more details on assembly naming: https://docs.microsoft.com/en-us/dotnet/framework/app-domains/assembly-names
#>
function Read-DirectoryAssembliesInfo {
    param(
      [string]$TargetDirectory
    )
  
    $assemblyInfoList = @()
  
    # Verify the target directory exists
    if (Test-Path $TargetDirectory) {
      # Fetch all DLL files in the target directory, including sub-directories
      $dllFileList = Get-ChildItem -Path $TargetDirectory -Filter "*.dll" -Recurse
  
      foreach ($singleDllFile in $dllFileList) {
        try {
          # Extract the AssemblyName object for each DLL
          $currentAssemblyName = [System.Reflection.AssemblyName]::GetAssemblyName($singleDllFile.FullName)
          
          # Create a custom PowerShell object and add it to the list
          $assemblyInfoList += [PSCustomObject]@{
            DllFilePath    = $singleDllFile.FullName
            FullAssemblyName = $currentAssemblyName.FullName
            AssemblyName   = $currentAssemblyName.Name
            AssemblyVersion = $currentAssemblyName.Version
          }
        } catch {
          Write-Verbose "Failed to inspect $($singleDllFile.FullName). Skipping."
        }
      }
    } else {
      Write-Verbose "The directory '$TargetDirectory' does not exist."
    }
    return $assemblyInfoList
  }
  
  <#
  .SYNOPSIS
      Sets the redirect paths for specified assemblies based on provided assembly information.
  
  .DESCRIPTION
      This function iterates through a list of assembly redirect information, searching for matching assemblies
      in the provided directory assemblies info. When a match is found, the redirect path for that assembly is set.
  
  .PARAMETER AssemblyRedirectInfo
      An array of custom hashtable objects that contain information for assembly redirects.
      Each object should have properties for AssemblyName, NewVersion, OldVersion, and RedirectPath.
  
  .PARAMETER DirectoryAssembliesInfo
      An array of custom objects that contain information about the assemblies in a directory.
      Each object should have properties for Name, Version, and DllPath.
  
  .EXAMPLE
      $redirectInfo = @(
          @{
              AssemblyName = 'System.Runtime.CompilerServices.Unsafe';
              NewVersion = '6.0.0.0';
              OldVersion = @{ Min = '0.0.0.0'; Max='4.0.4.1' };
              RedirectPath=$null
          }
      )
  
      $directoryInfo = Read-DirectoryAssembliesInfo -TargetDirectory "C:\MyDirectory"
  
      Set-AssemblyRedirects -AssemblyRedirectInfo $redirectInfo -DirectoryAssembliesInfo $directoryInfo
  
      Iterates through $redirectInfo and updates its RedirectPath based on the matching assemblies found in $directoryInfo.
  
  .NOTES
      This function modifies the input AssemblyRedirectInfo objects to set their RedirectPath properties.
      Make sure to provide mutable objects as input.
  
  .LINK
      For more details on assembly redirects: https://docs.microsoft.com/en-us/dotnet/framework/configure-apps/redirect-assembly-versions
  
  #>
  function Set-AssemblyRedirects {
      param(
          $AssemblyRedirectInfo,
          $DirectoryAssembliesInfo 
      )
  
      foreach ($redirect in $AssemblyRedirectInfo) {
          $matchingAssemblies = @()
  
          foreach ($assemblyInfo in $DirectoryAssembliesInfo) {
              if ($assemblyInfo.AssemblyName -eq $redirect.AssemblyName) {
                  if ($assemblyInfo.AssemblyVersion -eq [System.Version]$redirect.NewVersion) {
                      $matchingAssemblies += $assemblyInfo
                  }
              }
          }
  
          foreach ($assembly in $matchingAssemblies) {
              $redirect.RedirectPath = $assembly.DllFilePath
          }
      }
  }
  
<#
.SYNOPSIS
    Resolves and redirects assembly loading based on a list of assembly redirect information.

.DESCRIPTION
    The function takes a ResolveEventArgs object and an array of assembly redirect information to determine
    if an assembly should be redirected. If a match is found, the function returns the redirected assembly,
    otherwise it returns null.

.PARAMETER ResolveEventArgs
    A System.ResolveEventArgs object that contains the event data of the assembly to be resolved.

.PARAMETER AssemblyRedirectInfo
    An array of hashtables containing assembly redirect information. Each hashtable should have the following keys:
    - 'AssemblyName': The name of the assembly to redirect.
    - 'NewVersion': The new version number to redirect to.
    - 'OldVersion': A hashtable specifying the minimum ('Min') and maximum ('Max') version numbers to be redirected.
    - 'RedirectPath': The path to the redirected assembly.

.EXAMPLE
    $AssemblyRedirectInfo = @(
        @{ AssemblyName = 'Some.Assembly'; NewVersion = '2.0.0.0'; OldVersion = @{ Min = '1.0.0.0'; Max='1.9.9.9' }; RedirectPath=$null }
    )

    $OnAssemblyResolve = [System.ResolveEventHandler] {
        param ($objectsender, $resolveEventArgs)
        return Resolve-Assembly -ResolveEventArgs $resolveEventArgs -AssemblyRedirectInfo $AssemblyRedirectInfo
    }

.NOTES
    Make sure the 'RedirectPath' in the AssemblyRedirectInfo is populated before calling this function.
#>
function Resolve-Assembly {
    param(
        $ResolveEventArgs,
        $AssemblyRedirectInfo
    )

    $assemblyNameObj = New-Object System.Reflection.AssemblyName($ResolveEventArgs.Name)

    # Iterate through the redirects
    foreach ($redirect in $AssemblyRedirectInfo) {
        if ($assemblyNameObj.Name -eq $redirect.AssemblyName) {
            $assemblyVersion = [System.Version]::Parse($assemblyNameObj.Version)

            # Check if the assembly version falls within the specified range
            $minVersion = [System.Version]::Parse($redirect.OldVersion.Min)
            $maxVersion = [System.Version]::Parse($redirect.OldVersion.Max)

            if ($assemblyVersion -ge $minVersion -and $assemblyVersion -le $maxVersion -and $null -ne $redirect.RedirectPath) {
                return [System.Reflection.Assembly]::LoadFrom($redirect.RedirectPath)
            }
        }
    }
    return $null
}
  
  $OnAssemblyResolve = [System.ResolveEventHandler] {
    param ($objectsender, $resolveEventArgs)
    return Resolve-Assembly -ResolveEventArgs $resolveEventArgs -AssemblyRedirectInfo $AssemblyRedirectInfo
  }
  
  $DirectoryAssembliesInfo = Read-DirectoryAssembliesInfo -TargetDirectory "$PSScriptRoot"
  $AssemblyRedirectInfo = @(
      @{ AssemblyName = 'System.Runtime.CompilerServices.Unsafe'; NewVersion = '6.0.0.0'; OldVersion = @{ Min = '0.0.0.0'; Max='4.0.4.1' };  RedirectPath=$null }
  )
  
  Set-AssemblyRedirects -AssemblyRedirectInfo $AssemblyRedirectInfo -DirectoryAssembliesInfo $DirectoryAssembliesInfo 
  
  [system.appdomain]::currentdomain.add_assemblyresolve($OnAssemblyResolve)
  
  Import-Module -Name "$PSScriptRoot/CoreePower.Net.SoundCloudExplode.dll" -Force
  
  