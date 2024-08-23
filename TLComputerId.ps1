# Define the registry path and key name
$regPath = "HKLM:\SOFTWARE\ThreatLocker"
$keyName = "Computerid"

# Define the output file path
$outputFilePath = "C:\Temp\ThreatLockerComputerID.txt"

# Check if the registry key exists
if (Test-Path $regPath) {
    # Retrieve the Computerid value from the registry
    $computerID = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue

    if ($computerID) {
        # Write the Computerid value to the output file
        $computerIDValue = $computerID.$keyName
        $computerIDValue | Out-File -FilePath $outputFilePath -Encoding UTF8

        Write-Host "Computerid value '$computerIDValue' has been written to '$outputFilePath'."
    } else {
        Write-Host "The key '$keyName' was not found in the registry path '$regPath'."
    }
} else {
    Write-Host "The registry path '$regPath' does not exist."
}
