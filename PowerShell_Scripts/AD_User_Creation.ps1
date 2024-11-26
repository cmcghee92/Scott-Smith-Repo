Import-Module ActiveDirectory

$csvpath = "\\fileshare\users.csv"
$users = Import-Csv -Path $csvpath

foreach ($user in $users) {
    if (Get-Aduser -filter {samAccountName -eq $user.samAccountName}) {
        Write-Warning "A user account with username $($user.samAccountName) already exists in Active Directory."
    } else {
        New-Aduser `
        -SamAccountName $user.samAccountName `
        -UserPrincipleName "$($user.samAccountName)@domain.name" `
        -Name "$($user.FirstName) $($user.LastName)" `
        -GivenName $user.FirstName `
        -Surname $user.LastName `
        -DisplayName "$($user.LastName), $($user.FirstName), $($user.Department)" `
        -Path "OU=Users,DC=Domain,DC=Name" `
        -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force) `
        -Enabled $true `
        -ChangePasswordAtLogon $true

        Write-Host "Created User Account for $($user.FirstName) $($user.LastName)"
    }
}