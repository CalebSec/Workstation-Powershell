# Get the currently running services, processes, and autorun/autoload programs
function Get-SystemInfo {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [string]$ServiceOutputPath = "C:\Temp\Services.csv",
        [string]$ProcessOutputPath = "C:\Temp\Processes.csv",
        [string]$AutorunOutputPath = "C:\Temp\AutorunPrograms.csv"
    )

    begin {
        Write-Host "Pulling Services, Processes, and Autorun Programs"
    }
    
    process {
        # Get running services and export to CSV
        Get-Service | Where-Object { $_.Status -eq "Running" } |
            Select-Object -Property Name, DependentServices, @{Label="NoOfDependentServices"; Expression = { $_.DependentServices.Count }} |
            Export-Csv -Path $ServiceOutputPath -NoTypeInformation
        
        # Get processes and export to CSV
        Get-Process | ForEach-Object {
            $_.Modules | Select-Object -Property BasePriority, Id, SessionId, WorkingSet
        } |
            Export-Csv -Path $ProcessOutputPath -NoTypeInformation

        # Check autorun programs from Startup folder and Registry
        $startupFolders = @(
            "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
        )

        $autorunEntries = @()

        # Get autorun entries from Startup folders
        foreach ($folder in $startupFolders) {
            if (Test-Path $folder) {
                Get-ChildItem -Path $folder | ForEach-Object {
                    $autorunEntries += [PSCustomObject]@{
                        Name = $_.Name
                        Path = $_.FullName
                        Source = "Startup Folder"
                    }
                }
            }
        }

        # Get autorun entries from common Registry keys
        $registryPaths = @(
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
        )

        foreach ($regPath in $registryPaths) {
            if (Test-Path $regPath) {
                Get-ItemProperty -Path $regPath | ForEach-Object {
                    foreach ($property in $_.PSObject.Properties) {
                        $autorunEntries += [PSCustomObject]@{
                            Name = $property.Name
                            Path = $property.Value
                            Source = "Registry ($regPath)"
                        }
                    }
                }
            }
        }

        # Export autorun entries to CSV
        $autorunEntries | Export-Csv -Path $AutorunOutputPath -NoTypeInformation
    }
    
    end {
        Write-Host "Query is Complete"
    }
}
