

function Test-Write-FormatedText {
    param()
    [bool]$retval = $false;
    Write-FormatedText "Formated"
    $retval = $true
    return $retval
}
