## !!! UPDATE BOTH DATE VARIABLES BEFORE RUNNING REPORT !!! ###

# Load active directoru module
import-module ActiveDirectory

# Get list of computers to query
$computers = Get-ADComputer -Filter * | Where-Object { $_.Enabled -eq $true -AND $_.Name -notlike 'server0101' -AND $_.Name -notlike 'dc1vwdebssqlp02' } | Select-Object -ExpandProperty Name

# Initialize empty array which will hold the results of the remote commands executed for each server
$allServerInfo = @()

# Loop through each computer and execute the necessary commands
foreach ($computer in $computers) {

    # Use Invoke-Command to store information from the remote computers in a variable
    $remoteServerInfo = Invoke-Command -ComputerName $computer -ScriptBlock {

        # Define start and end dates for the updates range inside the remote session
        $startDate = [datetime]"2025-01-01"
        $endDate = [datetime]"2025-01-30"

        # Collect OS information on each remote servr
        $os = Get-ComputerInfo

        # Get installed updates within the date range
        $updates = Get-HotFix | Where-Object { 
            $_.InstalledOn -gt $startDate -and $_.InstalledOn -lt $endDate
        }

        # Create a custom object to store the local info
        $serverInfo = [PSCustomObject]@{
            Name            = $os.CsName
            OperatingSystem = $os.WindowsProductName
            HotFix          = ($updates | Select-Object -ExpandProperty HotFixID) -join ', ' # Join HotFixIDs into a string
        }

        # Tells PowerShell to "return" the value of $serverInfo from the script block running on the remote computer back to the local machine. "eturn" not required, $serverInfo alone works fine
        return $serverInfo 
    }
    
    # Append the server info from the pscustomobject to the empty array created above - this allows us to easier manage the objects returned from the remote command executed with Invoke-Command.
    # Allows us to easier manipulate the data below. Without this option additional properties are included in the file export - PSComputerName, RunspaceId 
    $allServerInfo += $remoteServerInfo
}


### Handling local updates here since Invoke-Command doesn't work on a local server ###

$startDate = [datetime]"2025-01-01"
$endDate = [datetime]"2025-01-30"
$localOS = Get-ComputerInfo

# Filter for updates on local server by date
$localUpdates = Get-HotFix -ComputerName dc1vwdebsbakp01 | Where-Object { 
            $_.InstalledOn -gt $startDate -and $_.InstalledOn -lt $endDate
        }

        # Create a custom object to store the local server info
        $localServerInfo = [PSCustomObject]@{
            Name            = $localOS.CsName
            OperatingSystem = $localOS.WindowsProductName
            HotFix          = ($localUpdates | Select-Object -ExpandProperty HotFixID) -join ', ' # Join HotFixIDs into a string
        }

# Append the local server info to the $allServerInfo array created above - now contains local and remote server data
$allServerInfo += $localServerInfo


# Export the desired results and format to CSV; added date formatting 12/18/24
$allServerInfo | select Name, OperatingSystem, HotFix | sort -Property OperatingSystem | Export-Csv "C:\Temp\PowerShell Reports\Windows Updates\Updates-$(get-date -f yyyy-MM-dd).csv" -Append -NoTypeInformation
