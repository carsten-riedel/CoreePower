param(
  [string]$Mode
)

Write-Host "debug.ps1 called in Mode: $Mode"

#You should dotsource all required files in you module
if ($Mode -eq "psm"){

    Set-Location -Path "C:\base\github.com\carsten-riedel\CoreePower\CoreePower.Module\src"
    PublishModule3
}

#You should dotsource all required files in you module, only exported function will be availible
if ($Mode -eq "psd"){
    
}

