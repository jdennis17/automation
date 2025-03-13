# NOTE - using the dbatools module to perform sql patches - https://dbatools.io/download/

# Provider username/password - required to use a network share with update file
$userName = Get-Credential

# Servers to updates
$servers = "server01","server02","server03"

# Update KB value and path 
Update-DbaInstance -ComputerName "$servers" -KB KB5046859 -Restart -Path "\\server\Software\SQL\Patches\" -Credential $userName -Confirm:$false -ExtractPath "\\server\Software\temp"
