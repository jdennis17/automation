#Date to DisableInactiveUsers
$date = (Get-Date).AddDays(-60) 

#CMD to write report to document updates to AD
Get-ADUser -searchbase "OU=xxxx,DC=xxxx,DC=xxxx" -Property Name,lastLogonDate,whencreated -Filter {(Enabled -eq $true) -and (lastLogonDate -lt $date)} | FT Name,lastLogonDate,whencreated | out-file "c:\Logs\DisabledAccounts\DisableInactiveUsers180days_$(get-date -f yyyy-MM-dd).txt"

#CMD to disable actual users
Get-ADUser -searchbase "OU=xxxx,DC=xxxx,DC=xxxx" -Property Name,lastLogonDate -Filter {(Enabled -eq $true) -and (lastLogonDate -lt $date)} | set-aduser -enabled $false
