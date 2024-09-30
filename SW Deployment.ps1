#This is a Chocolatey Software deployment for common software
#Prerequisite for this is to install the Chocolatey repository

#Setting the Execution Policy, setting the security protocol, and installing the repository
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install malwarebytes; 
choco install googleearth; 
choco install greenshot; 
choco install firefox; 
choco install dotnet-runtime; 
choco install dotnetcore-runtime; 
choco install dotnet-6.0-runtime; 
choco install dotnet-5.0-runtime; 
choco install dotnet-7.0-runtime; 
choco install javaruntime;
choco new Mobile_VPN_with_SSL;
start-process 'https://sync.myonlinedata.net/update/v1.0/installers?customization_id=ShareSync&client_type=Sync-WindowsApp';
Get-WindowsUpdate -AcceptAll -Install -AutoReboot 
