<#
.SYNOPSIS
Starts a new process without creating a visible window.

.DESCRIPTION
The Start-ProcessSilent function starts a new process with the specified file and arguments, and captures both the standard output and standard error streams. This function is designed to be used with applications that normally create a visible window, and suppresses the window from appearing on the desktop.

.PARAMETER File
The path to the file to be executed.

.PARAMETER Arguments
The arguments to be passed to the file.

.EXAMPLE
PS C:\> $output, $errorOutput = Start-ProcessSilent -File "$((Get-Command "cmd.exe").Path)" -Arguments "/C dir"
Starts the specified file with the specified arguments, and captures both the standard output and standard error streams.

#>
function Start-ProcessSilent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$File,

        [Parameter(Mandatory=$false)]
        [string]$Arguments = ""
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $File
    $psi.Arguments = $Arguments
    $psi.WorkingDirectory = [System.IO.Path]::GetDirectoryName($File)
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $process = [System.Diagnostics.Process]::Start($psi)
    $output = $process.StandardOutput.ReadToEnd()
    $errorOutput = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    return ,$output, $errorOutput
}


function Test-InteractiveShell {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param()

    $commandLineArgs = [Environment]::GetCommandLineArgs()
    $nonInteractiveArg = $commandLineArgs | Where-Object { $_ -like '*-NonInteractive*' }

    $isInteractive = [Environment]::UserInteractive -and (-not $nonInteractiveArg)

    return $isInteractive
}



function Restart-Proc {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param (
        [string]$InvokeCommand = "Restart-Proc",
        [bool]$ThisModuleScriptLoading = $false
    )

    if (-not(CanExecuteInDesiredScope -Scope ([Scope]::LocalMachine)))
    {
        $InteractiveShell = Test-InteractiveShell

        $currentPowershellProcess = Get-Process -Id $PID | Select-Object Path , CommandLine
        
        $manifestPath = ""
        $importOrDotSource = ""
        if ($ThisModuleScriptLoading)
        {
            if ($null -ne $MyInvocation.MyCommand.Module)
            {
                $manifestPath = (Get-Module -Name $MyInvocation.MyCommand.Module.Name).Path
            }
            $scriptPath = $MyInvocation.ScriptName
            if ($manifestPath -ne "")
            {
                $importOrDotSource = "Import-Module $manifestPath -DisableNameChecking"
            }
            else {
                $importOrDotSource = ". `"$scriptPath`""
            }
        }

        if ($InteractiveShell)
        {
            $CertAnswer = Confirm-AdminRightsEnabled
            if ($CertAnswer -eq 0)
            {
                Start-Process $currentPowershellProcess.Path -ArgumentList "-NoProfile -ExecutionPolicy ByPass -Command `"$importOrDotSource ; $InvokeCommand`" ; Start-Sleep 10" -Verb RunAs
            }
            return
        } else {
            Start-Process $currentPowershellProcess.Path -ArgumentList "-NoProfile -ExecutionPolicy ByPass -Command `"$importOrDotSource ; $InvokeCommand`" ; Start-Sleep 10" -Verb RunAs
            return
        }
    }
    else {
        Write-Host "Restart-Proc echo"
        Write-Host "Wait 10 seconds."
        Start-Sleep 10
    }
}
