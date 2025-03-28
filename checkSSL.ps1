<#

Need to run script with elevated prompt
Script fins SSL cert used for OneStream Web Server and check expiration date

#>

$hostname = hostname
$subject = "SSL Certificate Expiring"

# Empty array to store certificate information
$certRecords = @()

# Select the OneStream Web Server Site
$site = Get-WebSite -Name "Site"

# Select the OneStream Web Server Site binding information
$binding = Get-WebBinding -Name $site.name


if ($binding.protocol -eq "https") {
 
  Write-Output "HTTPS binding in use for $($site.name), additional certificate information below:"
 
  # Get certificate thumbprint
  $thumbprint = $binding.certificateHash
 
  # Search for certificates in the local cert store with matching thumbprint
  $certificates = Get-childitem -Path Cert:\LocalMachine -Recurse | where {$_.Thumbprint -eq $thumbprint}

 
  # if statement to check if thumbprint found and steps to perform
  if ($certificates) {
 
  # foreach loop required if certificate exists in multiple certstores. Also required for formatting the display results (returns one single line if not used)
  foreach ($certificate in $certificates) {

  # Using regex to shorten cert store location for cert
  $certPath = $certificate.PSParentPath
  $keyword = "Local"
  $path = $certPath -replace ".*(?=$keyword)", ""


  $certificateInfo = [PSCustomObject][ordered]@{

    'Certificate Store' = $path
    'Certificate Subject' = $certificate | select @{Name="Certificate Subject";Expression={$_.Subject}} -ExpandProperty Subject
    'Expiration Date' = $certificate.NotAfter

     }

   
   # Display the results of the information above
   Write-output $certificateInfo


   # Store results of foreach loop and custom object to empty array
   $certRecords += $certificateInfo

 }

 # Loop through the certs stored in the arry and check which ones are expiring, send an email alert
 foreach ($certRecord in $certRecords) {

   # Check if certs are expiring within a specific set of days from today
   if ($($certRecord.'Expiration Date') -lt (get-date).AddDays(30)) {
     
     # Using regex to remove excess info on certificate subject
     $subjKeyword = 'mil'
     $formattedSubject = $certRecord.'Certificate Subject' -replace "(?<=$subjKeyword).*", ""

     # Send email notification if certs are expiring using AWS SNS topic and subject - need to adjust permissions on IAM Role in order for email to send
     #$message = 'Server: ' + $hostname + ' - SSL Certificate Expiring: ' + $formattedSubject
     $message = 'Server: ' + $hostname + "`n" + 'SSL Certificate Expiring: ' + $formattedSubject + "`n" + 'Certificate Store: ' + $certRecord.'Certificate Store'
     aws sns publish --topic-arn arn:xxxxx --message $message --subject $Subject
   
   }

   else {

     Write-Output "No certificates are nearing expiration based on the specified parameters."

   }

 }

} else {

  Write-Output "Certificate thumbprint not found in local cert store.."

}

} else {

  Write-Output "HTTPS binding NOT in use.."

}
