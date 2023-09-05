
function Initialize-PackageManagement {
    # Suppress the use of unapproved verb in function name
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param ()


    # Get the local version of PowerShellGet
    $localPowerShellGetVersion = (Get-Module -Name PackageManagement).Version
    
    # Get the remote version of PowerShellGet from PSGallery
    $remotePowerShellGetVersion = [Version](Find-Module -Name PackageManagement -Repository PSGallery).Version

    # Store the original preference for showing progress
    $originalProgressPreference = $global:ProgressPreference
    
    # Compare local and remote versions
    if ($localPowerShellGetVersion -lt $remotePowerShellGetVersion) {
        
        # Temporarily disable the progress bar for this session
        $global:ProgressPreference = 'SilentlyContinue'
        
        # Install the newer version of PowerShellGet
        # - Force, AllowClobber, and SkipPublisherCheck are used to automate the installation
        Install-Module -Name PackageManagement -RequiredVersion $remotePowerShellGetVersion.ToString() -Scope CurrentUser -Repository PSGallery -Force -AllowClobber -SkipPublisherCheck | Out-Null

    }
    
    # Restore the original progress preference (in case of exceptions or early returns, this would still execute)
    $global:ProgressPreference = $originalProgressPreference
}