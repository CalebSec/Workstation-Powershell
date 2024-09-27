# Define the registry paths
$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\SYSTEM\CurrentControlSet\Services",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32",
    "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Windows",
    "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon",
    "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree",
    "HKLM:\SYSTEM\CurrentControlSet\Services",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\Software\Microsoft\Office",
    "HKCU:\Software\Microsoft\Office\15.0\Word\Security",
    "HKLM:\Software\Microsoft\Internet Explorer\Extensions",
    "HKCU:\Software\Microsoft\Internet Explorer\Extensions",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa",
    "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"
)

# Define log file path
$logFilePath = "C:\temp\registry_cleanup_log.txt"

# Function to log messages
function Log-Message {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$type] $message"
    Add-Content -Path $logFilePath -Value $logMessage
    Write-Host $logMessage
}

# Function to remove registry values
function Remove-RegistryValues {
    param (
        [string]$path
    )
    try {
        $key = Get-Item -Path $path -ErrorAction Stop
        $values = $key.GetValueNames()
        foreach ($value in $values) {
            Remove-ItemProperty -Path $path -Name $value -ErrorAction Stop
            Log-Message "Removed $value from $path"
        }
    } catch {
        Log-Message "Failed to remove values from $path: $_" "ERROR"
    }
}

# Set ErrorActionPreference to Stop to handle errors
$ErrorActionPreference = "Stop"

# Log start of script
Log-Message "Starting registry cleanup script"

# Loop through each registry path and remove values
foreach ($path in $registryPaths) {
    Log-Message "Processing registry path: $path"
    Remove-RegistryValues -path $path
}

# Log end of script
Log-Message "Completed registry cleanup script"
