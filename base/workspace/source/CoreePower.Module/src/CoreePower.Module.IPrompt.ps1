function Invoke-Prompt-Copy {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [Alias("ipt")] 
    param(
        [string]$PromptTitle = "Confirm Action",
        [string]$PromptMessage = "Do you want to proceed?",
        [string[][]]$PromptChoices = @(@('&Yes', 'Proceed with the action.'), @('&No', 'Cancel the action.')),
        [int]$DefaultChoiceIndex = 0,
        [bool]$DisplayChoicesBeforePrompt = $true
    )

    $choicesDesc = foreach($choice in $PromptChoices)
    {
        [System.Management.Automation.Host.ChoiceDescription]::new($choice[0], $choice[1])
    }

    if ($DisplayChoicesBeforePrompt)
    {
        foreach($choice in $PromptChoices)
        {
            $index = $choice[0].IndexOf('&')
            $nextCharacter = $choice[0].Substring($index + 1, 1).ToUpper()
            $PromptMessage += "`r`n$nextCharacter - $($choice[1])"
        }
    }

    try {
        $result = $Host.UI.PromptForChoice($PromptTitle, $PromptMessage, $choicesDesc, $DefaultChoiceIndex)
        return $result
    }
    catch {
        Write-Error "Error occurred while prompting for choice: $_"
        return -1
    }
}