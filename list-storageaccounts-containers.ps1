
$azureEnvironment    = "AzureUSGovernment"
$azureLocation       = "USGov Virginia"
$azureSubscriptionId = ""
$azureTenantId       = ""
$azureClientId       = ""
$azurePassword       = ConvertTo-SecureString "" -AsPlainText -Force
Write-Host "Logging in to Azure"
$psCred = New-Object System.Management.Automation.PSCredential($azureClientId , $azurePassword)
Connect-AzureRmAccount -Credential $psCred -TenantId $azureTenantId -EnvironmentName $azureEnvironment -ServicePrincipal


############

$context = Get-AzureRmContext

$storageAccounts = Get-AzureRmResource -ResourceType 'Microsoft.Storage/storageAccounts' 

[System.Collections.ArrayList]$saUsage = New-Object -TypeName System.Collections.ArrayList

 foreach ($storageAccount in $storageAccounts) {

   #list containers
   $containers= Get-AzureRmStorageContainer -ResourceGroupName $storageAccount.ResourceGroupName -StorageAccountName $storageAccount.Name
  
   
     if($containers -ne $null){
          foreach($container in $containers){
            $StorageAccountDetails = [ordered]@{
                    SubscriptionName = $context.Subscription.Name
                    SubscrpitionID = $context.Subscription.Id
                    StorageAccountName = $storageAccount.Name
                    ContainerName = $container.Name
                    ResourceGroup = $storageAccount.ResourceGroupName
                    Location = $storageAccount.Location
               }
             $saUsage.add((New-Object psobject -Property $StorageAccountDetails))  | Out-Null   
            }     
      }else{
      
        $StorageAccountDetails = [ordered]@{
                SubscriptionName = $context.Subscription.Name
                SubscrpitionID = $context.Subscription.Id
                StorageAccountName = $storageAccount.Name
                ContainerName = $null
                ResourceGroup = $storageAccount.ResourceGroupName
                Location = $storageAccount.Location      
         }
        $saUsage.add((New-Object psobject -Property $StorageAccountDetails)) | Out-Null
     }     
}
$saUsage | Export-Csv -Path C:\temp\file.csv -NoTypeInformation
