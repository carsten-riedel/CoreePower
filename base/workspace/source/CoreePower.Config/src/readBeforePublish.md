# Update the package provider
```
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Install-Module PowerShellGet -AllowClobber -Force
```

# Module .ps1 .psm1 must match the containing directory ..src\CoreePower.Config 
```
Publish-Module -Path "C:\base\github.com\carsten-riedel\CoreePower.Config\src\CoreePower.Config" -NuGetApiKey "key" -Repository "PSGallery" -Verbose
```

# Once Published install
```
Install-Module -Name CoreePower.Config -Scope CurrentUser -Force
```