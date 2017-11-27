Get-AzureRmResourceProvider -ProviderNamespace 'Microsoft.Automation' 

$BaseName = 'testautoacct'
$Location = 'eastus2'
$ResGrp = New-AzureRmResourceGroup -Name $BaseName -Location $Location -Verbose
$AutoAcct = New-AzureRmAutomationAccount -ResourceGroupName $ResGrp.ResourceGroupName -Name ($BaseName + $Location) -Location $ResGrp.Location 




$Stor = New-AzureRmStorageAccount -ResourceGroupName $ResGrp.ResourceGroupName -Name modulestor -SkuName Standard_LRS -Location $ResGrp.Location -Kind BlobStorage -AccessTier Hot

Add-AzureAccount
$Subscription = ((Get-AzureSubscription).where({$PSItem.SubscriptionName -eq 'LastWordInNerd'})) 
Select-AzureSubscription -SubscriptionName $Subscription.SubscriptionName -Current

$StorKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $Stor.ResourceGroupName -Name $Stor.StorageAccountName).where({$PSItem.KeyName -eq 'key1'})
$StorContext = New-AzureStorageContext -StorageAccountName $Stor.StorageAccountName -StorageAccountKey $StorKey.Value





$Container = New-AzureStorageContainer -Name 'modules' -Permission Blob -Context $StorContext -Permission Blob 




$ModuleLoc = 'C:\Scripts\Presentations\OMSAutomation\Modules\'
$Modules = Get-ChildItem -Directory -Path $ModuleLoc
    
    ForEach ($Mod in $Modules){

        Compress-Archive -Path $Mod.PSPath -DestinationPath ($ModuleLoc + '\' + $Mod.Name + '.zip') -Force

    }

$ModuleArchive = Get-ChildItem -Path $ModuleLoc -Filter "*.zip"

ForEach ($Mod in $ModuleArchive){
        
    $Blob = Set-AzureStorageBlobContent -Context $StorContext -Container $Container.Name -File $Mod.FullName -Force -Verbose
    New-AzureRmAutomationModule -ResourceGroupName $ResGrp.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName -Name ($Mod.Name).Replace('.zip','') -ContentLink $Blob.ICloudBlob.Uri.AbsoluteUri

} 



