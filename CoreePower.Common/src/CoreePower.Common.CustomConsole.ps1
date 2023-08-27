function Write-Notice {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("wn")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$text
    )
    Write-Host "$text" -ForegroundColor White -BackgroundColor Green
}

<#
if ($Host.Name -match "Visual Studio Code")
{
    Test.CoreePower.Lib.Initialize.DevTools.Baget
}
#>