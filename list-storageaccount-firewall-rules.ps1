#Connect-AzAccount
$Result=@()
$Storageaccounts = Get-AzureRMStorageAccount
$Storageaccounts | ForEach-Object {
$storageaccount = $_
Get-AzureRMStorageAccountNetworkRuleSet -ResourceGroupName $storageaccount.ResourceGroupName -AccountName $storageaccount.StorageAccountName | ForEach-Object {
$Result += New-Object PSObject -property @{ 
Account = $storageaccount.StorageAccountName
ResourceGroup = $storageaccount.ResourceGroupName
Bypass = $_.Bypass
Action = $_.DefaultAction
IPrules = $_.IpRules
Vnetrules = $_.VirtualNetworkRules
ResourceRules = $_.ResourceAccessRules
}
}
}
$Result | Select Account,ResourceGroup,Bypass,Action,IPrules,Vnetrules,ResourceRules