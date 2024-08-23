#Install AzureConnect Module
#Install-Module AzureAD

#Connect To AzureConnect
Connect-AzureAD


# Get all users
$AllUsers = Get-AzureADUser -All $true

# Initialize an array to hold users without MFA
$UsersWithoutMFA = @()

# Loop through each user and check their MFA status
foreach ($User in $AllUsers) {
    $MFAStatus = Get-MsolUser -UserPrincipalName $User.UserPrincipalName | Select-Object -ExpandProperty StrongAuthenticationMethods
    if ($MFAStatus.Count -eq 0) {
        $UsersWithoutMFA += $User
    }
}

# Export the list to a CSV file
$UsersWithoutMFA | Select-Object DisplayName, UserPrincipalName | Export-Csv -Path "C:\Temp\<Filename>.csv" -NoTypeInformation
