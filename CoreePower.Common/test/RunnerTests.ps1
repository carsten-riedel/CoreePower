

function Test-Write-Notice {
    param()
    [bool]$retval = $false;
    wn "foo"
    $retval = $true
    return $retval
}

function Test-Write-FormatedText {
    param()
    [bool]$retval = $false;
    Write-FormatedText "foo"
    $retval = $true
    return $retval
}

function Test-Invoke-Prompt {
    param()
    [bool]$retval = $false;
    Invoke-Prompt
    $retval = $true
    return $retval
}

function Test-Confirm-AdminRightsEnabled {
    param()
    [bool]$retval = $false;
    Confirm-AdminRightsEnabled
    $retval = $true
    return $retval
}


