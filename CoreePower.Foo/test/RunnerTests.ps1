    function Test-SampleFunction {
        param()
        [bool]$retval = $false;
        SampleFunction
        [bool]$retval = $true
        return $retval
    }
