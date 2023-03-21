# Selecting VM snapshots
$snapshots = Get-AzureRmSnapshot | select name, resourcegroupname, timecreated, @{name="Size(GB)";expression={($_.disksizegb)}} | sort TimeCreated

# Selecting snapshosts based on certain time range and measuring by disk size  
$totalsize = Get-AzureRmSnapshot | select name, resourcegroupname, timecreated, disksizegb | where {$_.timecreated -lt ([datetime]::Now.AddDays(-180))} | Measure-Object -Property disksizegb -Sum 

# Specifying the sum property measurement of the disk size property 
[int]$total = ($totalsize).Sum

Write-Output "Getting VM snapshosts for removal ...`n"

foreach ($snapshot in $snapshots) {
    
    # Looping through snapshots and listing based on time range - NEED TO ADD remove-azurermsnapshot -force COMMMAND TO DELETE SNAPSHOTS!!
    $snapshot | where {$_.timecreated -lt ([datetime]::Now.AddDays(-180))} 
  
}

# Displaying total GB deleted from snapshosts removed
Write-Output "`n `n Total GB to be deleted from snapshots is $total GB"
