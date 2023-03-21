## Settings below pulled from Azure Portal and Ansible Server - /etc/profile.d/azure_service_principal.sh file
$azureEnvironment    = "AzureUSGovernment"
$azureLocation       = "USGov Virginia"
$azureSubscriptionId = "77500eef-8657-4927-8c3b-68ef341a9af3"
$azureTenantId       = "0ed52ee3-ab90-4e18-ac02-a60dcc265704"
$azureClientId       = "40e86467-4ae4-40ad-ae63-aad2bf98d990"
$azurePassword       = ConvertTo-SecureString "af33c19b-4d5f-49ec-a469-181efecbcfc0" -AsPlainText -Force
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
$saUsage | Export-Csv -Path C:\Users\JAMES.DENNIS\Desktop\storageaccounts\devlab+test-storage.csv -NoTypeInformation