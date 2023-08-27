<#
.SYNOPSIS
Writes a string message to the console with a green background and white foreground.

.DESCRIPTION
The Write-Notice function outputs a string message to the console with a specified styling: white foreground text on a green background. This is useful for displaying important or highlighted messages in your scripts.

.PARAMETER text
The string message you want to display in the console. This is a mandatory parameter and cannot be null or empty.

.EXAMPLE
Write-Notice "Hello, World!"
This example writes "Hello, World!" to the console with a green background and white text.

.EXAMPLE
wn "Hello again!"
Using the alias 'wn', this example writes "Hello again!" to the console with a green background and white text.

.NOTES
- The function suppresses PSUseApprovedVerbs warning as "Notice" is not an approved PowerShell verb.
- This function uses Write-Host for the output. If you want to capture the output into a variable or file, you may need to modify the function.

#>
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