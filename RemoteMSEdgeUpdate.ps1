
# Load active directory module
import-module ActiveDirectory

# Get list of computers to query - exclude server where script is running from 
$computers = Get-ADComputer -Filter * | Where-Object { $_.Enabled -eq $true -AND $_.Name -notlike 'server01' -AND $_.Name -notlike 'server02' -AND $_.Name -notlike 'server03'} | Select-Object -ExpandProperty Name

# Initialize empty array which will hold the results of the remote commands executed for each server
$allServerInfo = @()

# Loop through each computer and execute the necessary commands
foreach ($computer in $computers) {

    # Use Invoke-Command to store information from the remote computers in a variable
    $remoteServerInfo = Invoke-Command -ComputerName $computer -ScriptBlock {

    # Get host name and current Edge version installed - casting the version as System.Version class since by default its a string type value
    $os = Get-ComputerInfo
    $currentEdgeVersion = [System.Version](Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo.ProductVersion

    
    # Upgrade MS Edge
    try {

      Start-Process -FilePath "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe" -argumentlist "/silent /install appguid={56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}&appname=Microsoft%20Edge&needsadmin=True" -Wait -ErrorAction Stop  # This will stop execution if there's an error

      #Write-Host "Upgrade complete or not required at this time."

    } catch {

      Write-Host "An error occurred: $_"  # Any error above is passed to the catch block

    }

    # Check MS Edge Version post update 
    $updatedEdgeVersion = [System.Version](Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo.ProductVersion

    
    # Create a custom object to store the local info
    $serverInfo = [PSCustomObject]@{
      Name            = $os.CsName
      "Operating System" = $os.WindowsProductName
      "Current Version" = $currentEdgeVersion
      "Updated Version" = $updatedEdgeVersion

        }

        return $serverInfo
  }

  # Add the remote server data gathered from script block to empty array 
  $allServerInfo += $remoteServerInfo

}

### Handling local updates here since Invoke-Command doesn't work on a local server ###

# Get host name and current Edge version installed - casting the version as System.Version class since by default its a string type value
$localOS = Get-ComputerInfo
$localCurrentVersion = [System.Version](Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo.ProductVersion


    # Upgrade MS Edge
    try {

      Start-Process -FilePath "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe" -argumentlist "/silent /install appguid={56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}&appname=Microsoft%20Edge&needsadmin=True" -ErrorAction Stop  # This will stop execution if there's an error

      Write-Host "Upgrade complete or not required at this time."

    } catch {

      Write-Host "An error occurred: $_"  # Any error above is passed to the catch block

    }

    # Check MS Edge Version post update 
    $localUpdatedVersion = [System.Version](Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo.ProductVersion

    # Create a custom object to store the local info
    $localServerInfo = [PSCustomObject]@{
      Name            = $localOS.CsName
      "Operating System" = $localOS.WindowsProductName
      "Current Version" = $localCurrentVersion
      "Updated Version" = $localUpdatedVersion

        }

# Add local server information to array containing remote server data
$allServerInfo += $localServerInfo

# Output all server information and selected properties
$allServerInfo | select Name, "Operating System", "Current Version", "Updated Version" 

