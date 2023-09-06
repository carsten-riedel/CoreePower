<#
.SYNOPSIS
    Initializes the PowerShellGet module by checking for updates and setting PSGallery as a trusted source.

.DESCRIPTION
    The Initialize-PowerShellGet function performs the following actions:
    - Compares the local and remote versions of the PowerShellGet module.
    - Updates the module if a newer version is available on PSGallery.
    - Sets PSGallery as a trusted package source.

.NOTES
    - Uses global scope for ProgressPreference to suppress progress bars during execution.
    - Security flags like AllowClobber and SkipPublisherCheck are used for automated installation.
#>
function Initialize-PowerShellGet {
    # Suppress the use of unapproved verb in function name
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param ()

    # Set PSGallery as a trusted package source
    Set-PackageSource -Name PSGallery -Trusted -ProviderName PowerShellGet | Out-Null

    # Get the local version of PowerShellGet
    $localPowerShellGetVersion = (Get-Module -Name PowerShellGet).Version
    
    # Get the remote version of PowerShellGet from PSGallery
    $remotePowerShellGetVersion = [Version](Find-Module -Name PowerShellGet -Repository PSGallery).Version
    
    # Compare local and remote versions
    if ($localPowerShellGetVersion -lt $remotePowerShellGetVersion) {

        # Store the original preference for showing progress
        $originalProgressPreference = $global:ProgressPreference
        
        # Temporarily disable the progress bar for this session
        $global:ProgressPreference = 'SilentlyContinue'
        
        # Install the newer version of PowerShellGet
        # - Force, AllowClobber, and SkipPublisherCheck are used to automate the installation
        Install-Module -Name PowerShellGet -RequiredVersion $remotePowerShellGetVersion.ToString() -Scope CurrentUser -Repository PSGallery -Force -AllowClobber -SkipPublisherCheck | Out-Null
        
        # Restore the original progress preference
        $global:ProgressPreference = $originalProgressPreference
    }
    

}
