param(
  [string]$Mode
)

Write-Host "debug.ps1 called in Mode: $Mode"

#You should dotsource all required files in you psm1 file.
if ($Mode -eq "psm"){

    #Set-Location -Path "C:\base\github.com\carsten-riedel\CoreePower\CoreePower.Module"
    #UpdateModule3
    #PublishModule4
    #CreateModule2 -Nested "src" -ModuleName "CoreePower.Common" -Description "Library for module management" -Author "Carsten Riedel"
    #Set-Location -Path "C:\base\github.com\carsten-riedel\CoreePower\CoreePower.Common"
    #UpdateModule3
}

#You should dotsource all required files in you psm1 file. Only exported definitions in you psd1 will be availible.
if ($Mode -eq "psd"){
    
}

