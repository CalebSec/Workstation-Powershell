# Script to remediate CVE-2024-52535
function Check-And-Update-SupportAssist {
     # Function to check if the device is a Dell
     function Is-DellDevice {
            $manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
            return $manufacturer -like "*Dell*"
        }

        # Check if the device is a Dell
        if (-not (Is-DellDevice)) {
            Write-Host "This device is not manufactured by Dell. Exiting script."
            return
        }

        Write-Host "Dell device detected. Proceeding with SupportAssist check..."

    # Define the minimum required version
    $minVersion = [Version]"4.5.1"  # Replace with the minimum version you require
    $supportAssistURL = "https://downloads.dell.com/serviceability/catalog/SupportAssistInstaller.exe"  # URL for the latest installer
    $installerPath = "$env:TEMP\SupportAssistInstaller.exe"

    # Check for SupportAssist using WMI
    $supportAssist = Get-CimInstance -ClassName Win32_Product | Where-Object {
        $_.Name -like "*SupportAssist*"
    }

    if ($supportAssist) {
        # Parse the current version
        $currentVersion = [Version]$supportAssist.Version

        # Compare versions
        if ($currentVersion -le $minVersion) {
            Write-Host "SupportAssist version $currentVersion is below or equal to the minimum version $minVersion."
            Write-Host "Updating SupportAssist..."

            # Download the installer
                $headers = @{
                    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
                        }
                Invoke-WebRequest -Uri $supportAssistURL -Headers $headers -OutFile $installerPath -ErrorAction Stop

            # Run the installer
            Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait

            Write-Host "SupportAssist has been updated to the latest version."
        } else {
            Write-Host "SupportAssist is already up-to-date (version $currentVersion)."
        }
    } else {
        Write-Host "Dell SupportAssist is not installed. Downloading and installing the latest version..."

        # Download the installer
        Invoke-WebRequest -Uri $supportAssistURL -OutFile $installerPath -ErrorAction Stop

        # Run the installer
        Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait

        Write-Host "Dell SupportAssist has been installed."
    }

    # Cleanup the installer file
    if (Test-Path $installerPath) {
        Remove-Item -Path $installerPath -Force
    }
}

# Run the function
Check-And-Update-SupportAssist
