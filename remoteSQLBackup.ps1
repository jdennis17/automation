##############
# 
#  *** Update search filter path, server names, update database names and backup paths ***
# 
##############

# Selecting SQL servers - UPDATE THESE SERVERS TO POINT TO PROD !!! ***** 
$servers = Get-ADComputer -Filter * -SearchBase "OU=xxxx,OU=xxxx,DC=xxxx,DC=xxx,DC=xxxx" | `
where { $_.Name -like 'server01' -OR $_.Name -like 'server02' -OR $_.Name -like 'server03' } | `
select Name -ExpandProperty Name

# Executing script block to perform sql backups on remote servers selected above
Invoke-Command -ComputerName $servers -ScriptBlock {
  
  # Use if statements below to determine server we're connected to which determines database to backup and path for backup
  if ($env:COMPUTERNAME -eq "server01") {
   
    $date = (Get-Date -Format "yyyyMMdd")
    $db = Get-SqlDatabase -ServerInstance localhost -Name "" | select Name -ExpandProperty Name

    Backup-SqlDatabase -ServerInstance localhost -Database "" -BackupFile "F:\SQLBACKUPS\$($db)_$($date).bak" -CompressionOption On

  } elseif ($env:COMPUTERNAME -eq "server01") {
    
    $date = (Get-Date -Format "yyyyMMdd")
    $db = Get-SqlDatabase -ServerInstance localhost -Name "" | select Name -ExpandProperty Name

    Backup-SqlDatabase -ServerInstance localhost -Database "" -BackupFile "F:\SQLBACKUPS\$($db)_$($date).bak" -CompressionOption On

  } elseif ($env:COMPUTERNAME -eq "server01") {
    
    $date = (Get-Date -Format "yyyyMMdd")
    $db1 = Get-SqlDatabase -ServerInstance localhost -Name "" | select Name -ExpandProperty Name
    $db2 = Get-SqlDatabase -ServerInstance localhost -Name "" | select Name -ExpandProperty Name
    $db3 = Get-SqlDatabase -ServerInstance localhost -Name "" | select Name -ExpandProperty Name
    $db4 = Get-SqlDatabase -ServerInstance localhost -Name "" | select Name -ExpandProperty Name

    
    #Backup-SqlDatabase -ServerInstance localhost -Database "" -BackupFile "F:\BACKUPS\FULL\$($db1)_$($date).bak" -CompressionOption On
    Backup-SqlDatabase -ServerInstance localhost -Database "" -BackupFile "F:\SQLBACKUPS\$($db2)_$($date).bak" -CompressionOption On
    Backup-SqlDatabase -ServerInstance localhost -Database "" -BackupFile "F:\SQLBACKUPS\$($db3)_$($date).bak" -CompressionOption On
    Backup-SqlDatabase -ServerInstance localhost -Database "" -BackupFile "F:\SQLBACKUPS\$($db4)_$($date).bak" -CompressionOption On

  }

}
