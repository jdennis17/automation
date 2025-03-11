
# Load Active Directory module
import-module ActiveDirectory

# Get list of computers to query
$computers = Get-ADComputer -Filter * | Where-Object { $_.Enabled -eq $true -AND $_.Name -notlike 'server01' -AND $_.Name -notlike 'server02' } | Select-Object -ExpandProperty Name

# Initialize empty array which will hold the results of the remote commands executed for each server
$allServerInfo = @()

# Loop through each of the computers filtered above 
foreach ($computer in $computers) {
      
    # Use invoke command to remotely connect to computers - the section belows works with or without $remoteDiskSpace; using $remoteDiskSpace prevents output to the screen
    $remoteDiskSpace = Invoke-Command -ComputerName $computer -ScriptBlock {

        # Select Server and OS information
        $osinfo = Get-CimInstance -ClassName Win32_OperatingSystem | select @{name="Server Name";expression={$_.csname}}, @{name="Operating System";expression={$_.caption}}

        # Count of total physical CPU
        $physicalCPU = (Get-CimInstance -ClassName Win32_Processor).Count 

        # Total cores
        $totalCores = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum

        # Listing local drives, excluding CD and system reserved; using hash table to modify properties and math class to round decimal places
        $disks = Get-Volume | Where-Object { $_.DriveLetter -ne $null -and $_.DriveLetter -ne "" -and $_.DriveType -ne "CD-ROM" } | Select-Object DriveLetter, 
            @{name="Size Remaining (GB)";expression={[math]::Round($_.SizeRemaining / 1gb, 2)}}, 
            @{name="Total Size (GB)";expression={[math]::Round($_.Size / 1gb, 2)}}

        # Create a custom object to store the server info - server name, cpu, cores
        $serverInfo = [PSCustomObject]@{
            'Server Name'     = $osinfo.'Server Name'
            'Operating System' = $osinfo.'Operating System'
            'Physical CPU'    = $physicalCPU
            'Total Cores'     = $totalCores
        }

        # Create custom objects for server disk information; loop through each disk and grab the necessary info
        $diskObjects = $disks | ForEach-Object {
            [PSCustomObject]@{
                'Server Name'         = $osinfo.'Server Name'
                'Operating System'    = $osinfo.'Operating System'
                'Physical CPU'        = $physicalCPU
                'Total Cores'         = $totalCores
                'DriveLetter'         = $_.DriveLetter
                'Size Remaining (GB)' = $_.'Size Remaining (GB)'
                'Total Size (GB)'     = $_.'Total Size (GB)'
            }
        }

        # Return the disk info 
        return $diskObjects

    }
    
    # Append the disk info directly to the allServerInfo array
    $allServerInfo += $remoteDiskSpace
}


## GRABBING LOCAL SERVER INFORMATION... 

# Select local server and OS information
        $localOSInfo = Get-CimInstance -ClassName Win32_OperatingSystem | select @{name="Server Name";expression={$_.csname}}, @{name="Operating System";expression={$_.caption}}

        # Count of total physical CPU
        $localPhysicalCPU = (Get-CimInstance -ClassName Win32_Processor).Count 

        # Total logical cores
        $localTotalCores = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum

        # Listing local drives, excluding CD and system reserved; using hash table to modify properties and math class to round decimal places
        $localDisks = Get-Volume | Where-Object { $_.DriveLetter -ne $null -and $_.DriveLetter -ne "" -and $_.DriveType -ne "CD-ROM" } | Select-Object DriveLetter, 
            @{name="Size Remaining (GB)";expression={[math]::Round($_.SizeRemaining / 1gb, 2)}}, 
            @{name="Total Size (GB)";expression={[math]::Round($_.Size / 1gb, 2)}}

        # Create a custom object to store the server info - server name, cpu, cores
        $localServerInfo = [PSCustomObject]@{
            'Server Name'     = $localOSInfo.'Server Name'
            'Operating System' = $localOSInfo.'Operating System'
            'Physical CPU'    = $localPhysicalCPU
            'Total Cores'     = $localTotalCores
        }

        # Create custom objects for server disk information; loop through each disk and grab the necessary info
        $localDiskObjects = $localDisks | ForEach-Object {
            [PSCustomObject]@{
                'Server Name'         = $localOSInfo.'Server Name'
                'Operating System'    = $localOSInfo.'Operating System'
                'Physical CPU'        = $localPhysicalCPU
                'Total Cores'         = $localTotalCores
                'DriveLetter'         = $_.DriveLetter
                'Size Remaining (GB)' = $_.'Size Remaining (GB)'
                'Total Size (GB)'     = $_.'Total Size (GB)'
            }
        }


# Add local disk info to arry holding remote server info
$allServerInfo +=$localDiskObjects    

# Export the data to CSV
$allServerInfo | Select 'Server Name', 'Operating System', 'Physical CPU', 'Total Cores', DriveLetter, 'Size Remaining (GB)', 'Total Size (GB)' | Sort -Property 'Server Name' | Export-Csv -Path "C:\Temp\PowerShell Reports\Disk Space\DiskSpace_$(get-date -f yyyy-MM-dd).csv" -NoTypeInformation
