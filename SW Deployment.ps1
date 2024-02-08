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
