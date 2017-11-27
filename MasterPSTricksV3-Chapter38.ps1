$AutoResGrp = Get-AzureRmResourceGroup -Name 'mms-eus'
$StorAcct = Get-AzureRmStorageAccount -ResourceGroupName $AutoResGrp.ResourceGroupName -Name 'modulestor'


#Now that we have our private store, we're going to publish our configuration using the Publish-AzureRmVMDscConfiguration command.


$DSCBlob = Publish-AzureRmVMDscConfiguration -ConfigurationPath C:\Scripts\Configs\cmdpconfig.ps1 -ResourceGroupName $StorAcct.ResourceGroupName -ContainerName 'dscpushconfig' -StorageAccountName $StorAcct.StorageAccountName -Force

$Archive = $DSCBlob.Split('/') | Select-Object -Last 1 





$ArmVmRsg = Get-AzureRmResourceGroup -Name 'nrdtste'
$ArmVm = Get-Azurermvm -ResourceGroupName $ArmVmRsg.ResourceGroupName -Name 'ctrxeusdbnp01'
Set-AzureRmVMDscExtension -ArchiveResourceGroupName $StorAcct.ResourceGroupName -ArchiveBlobName $Archive -ResourceGroupName $ArmVm.ResourceGroupName -ArchiveStorageAccountName $StorAcct.StorageAccountName -ArchiveContainerName 'dscpushconfig' -Version '2.26' -VMName $ArmVm.Name -ConfigurationName 'CMDPConfig' -Verbose




Get-AzureRmVMDscExtensionStatus -ResourceGroupName $ArmVm.ResourceGroupName -VMName $ArmVm.Name



(Get-AzureRmVMDscExtensionStatus -ResourceGroupName $ArmVm.ResourceGroupName -VMName $Armvm.Name).DscConfigurationLog 


