
# Function to get latest Chrome version from Appspot
function Get-LatestChromeStable {
    try {
        $uri = "https://chromiumdash.appspot.com/releases?platform=Windows"
        $resp = Invoke-RestMethod -Uri $uri -UseBasicParsing
        # Find the stable release with the highest version number
        $stableRelease = $resp | Where-Object { $_.channel -eq "Stable" } | Sort-Object version -Descending | Select-Object -First 1
        return $stableRelease.version
    }
    catch {
        Write-Host "Warning: Could not retrieve latest Chrome version from Chromium Dash API." -ForegroundColor Yellow
        return $null
    }
}

# Function to get latest Edge info (version and MSI URL)
function Get-EdgeLatestInfo {
    try {
        $uri = "https://edgeupdates.microsoft.com/api/products"
        $data = Invoke-RestMethod -Uri $uri -UseBasicParsing
        $windowsReleases = $data.Releases | Where-Object { $_.Platform -eq 'Windows' -and $_.Architecture -eq 'x64' -and $_.Product -eq 'Stable' }
        $latest = $windowsReleases | Sort-Object -Property ProductVersion -Descending | Select-Object -First 1
        $msiUrl = ($latest.Artifacts | Where-Object { $_.ArtifactName -eq 'msi' }).Location
        return @{ Version = $latest.ProductVersion; MsiUrl = $msiUrl }
    } catch {
        Write-Host "Could not retrieve latest Edge version: $_" -ForegroundColor Yellow
        return $null
    }
}

# Function to compare versions and update if needed
function Get-BrowserVersion {
    param (
        [string]$AppName,
        [string[]]$RegistryPaths,
        [string[]]$ExePaths,
        [ScriptBlock]$GetLatestVersion
    )

    $installedVersion = $null
    $source = $null

    foreach ($path in $RegistryPaths) {
        try {
            $reg = Get-ItemProperty -Path $path -ErrorAction Stop
            if ($reg.version) {
                $installedVersion = $reg.version
                $source = "Registry ($path)"
                break
            }
        } catch {}
    }

    if (-not $installedVersion) {
        foreach ($path in $ExePaths) {
            if (Test-Path $path) {
                try {
                    $installedVersion = (Get-Item $path).VersionInfo.ProductVersion
                    $source = "EXE ($path)"
                    break
                } catch {}
            }
        }
    }

    if (-not $installedVersion) {
        Write-Host "$AppName not found." -ForegroundColor Yellow
        return
    }

    $latest = & $GetLatestVersion
    $latestVersion = $latest
    if ($AppName -eq "Microsoft Edge") {
        $latestVersion = $latest.Version
    }

    $isCompliant = $installedVersion -eq $latestVersion
    $status = if ($isCompliant) { "(Compliant)" } else { "(NOT compliant, latest is $latestVersion)" }
    Write-Host "$AppName version: $installedVersion $status [$source]"

    if (-not $isCompliant) {
        Force-BrowserUpdate -AppName $AppName
    }
}

# Function to install/update browsers
function Force-BrowserUpdate {
    param (
        [string]$AppName
    )

    if ($AppName -eq "Google Chrome") {
        try {
            Start-Process "C:\Program Files (x86)\Google\GoogleUpdater\141.0.7340.0\updater.exe" -ArgumentList "/silent /install /norestart" -Wait
             Write-Host "Chrome update completed." -ForegroundColor Green
        } Catch {
            Write-Host "Chrome Update executable not found" -ForegroundColor Red
        }  
       

    } elseif ($AppName -eq "Microsoft Edge") {
        $edgeInfo = $Global:EdgeLatestInfo
        if ($edgeInfo -and $edgeInfo.MsiUrl) {
            Write-Host "Updating Microsoft Edge..."
            try {
                Start-Process "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe" -ArgumentList "/silent /install /norestart" -Wait
                Write-Host "Edge update completed." -ForegroundColor Green
            } catch {
                Write-Host "Update failed for Microsoft Edge: Update executable not found" -ForegroundColor Red
            }
        } 
    }

}

# Firefox simple check
function Ensure-FirefoxCompliant {
    $firefoxPath = "C:\\Program Files\\Mozilla Firefox\\firefox.exe"
    if (-not (Test-Path $firefoxPath)) {
        Write-Host "WARNING: Firefox not found." -ForegroundColor Yellow
    } else {
        $version = (Get-Item $firefoxPath).VersionInfo.ProductVersion
        Write-Host "Firefox version: $version Updating now"
    }
    if($version) {
        $Script:Firefox = $firefox
    }
}

function Firefox-Update {
    if ($firefox) {
        Start-Process "C:\Program Files (x86)\Mozilla Maintenance Service\maintenanceservice.exe" -ArgumentList "/silent /install /norestart" -Wait
    }
}

# Registry and paths for browser checks
$chromeReg = @("HKCU:\SOFTWARE\Google\Chrome\BLBeacon")
$edgeReg = @("HKCU:\SOFTWARE\Microsoft\Edge\BLBeacon")
$chromeExe = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe")
$edgeExe = @("$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe")

# Global cache of latest Edge info
$Global:EdgeLatestInfo = Get-EdgeLatestInfo

# Run checks
Get-BrowserVersion -AppName "Google Chrome" -RegistryPaths $chromeReg -ExePaths $chromeExe -GetLatestVersion ${function:Get-LatestChromeStable}
Get-BrowserVersion -AppName "Microsoft Edge" -RegistryPaths $edgeReg -ExePaths $edgeExe -GetLatestVersion { return $Global:EdgeLatestInfo }
Ensure-FirefoxCompliant