
     $AdminCreds = Get-AutomationPSCredential -Name $AdminName

    Node ($AllNodes.Where{$_.Role -eq "WebServer"}).NodeName
    {
            
            JoinDomain DomainJoin
            {
                DependsOn = "[WindowsFeature]RemoveUI"
                DomainName = $DomainName
                Admincreds = $Admincreds
                RetryCount = 20
                RetryIntervalSec = 60
            }

   
    }


    #region GetAutomationAccount

$AutoResGrp = Get-AzureRmResourceGroup -Name 'mms-eus'
$AutoAcct = Get-AzureRmAutomationAccount -ResourceGroupName $AutoResGrp.ResourceGroupName

#endregion

#region compress configurations

    Set-Location C:\Scripts\Presentations\AzureAutomationDSC\ResourcesToUpload
    $Modules = Get-ChildItem -Directory
    
    ForEach ($Mod in $Modules){

        Compress-Archive -Path $Mod.PSPath -DestinationPath ((Get-Location).Path + '\' + $Mod.Name + '.zip') -Force

    }


#endregion

#region Access blob container

$StorAcct = Get-AzureRmStorageAccount -ResourceGroupName $AutoAcct.ResourceGroupName

Add-AzureAccount
$AzureSubscription = ((Get-AzureSubscription).where({$PSItem.SubscriptionName -eq $Sub.Name})) 
Select-AzureSubscription -SubscriptionName $AzureSubscription.SubscriptionName -Current
$StorKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $StorAcct.ResourceGroupName -Name $StorAcct.StorageAccountName).where({$PSItem.KeyName -eq 'key1'})
$StorContext = New-AzureStorageContext -StorageAccountName $StorAcct.StorageAccountName -StorageAccountKey $StorKey.Value
$Container = Get-AzureStorageContainer -Name ('modules') -Context $StorContext


#endregion

#region upload zip files

$ModulesToUpload = Get-ChildItem -Filter "*.zip"

ForEach ($Mod in $ModulesToUpload){

        $Blob = Set-AzureStorageBlobContent -Context $StorContext -Container $Container.Name -File $Mod.FullName -Force
        
        New-AzureRmAutomationModule -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName -Name ($Mod.Name).Replace('.zip','') -ContentLink $Blob.ICloudBlob.Uri.AbsoluteUri

}


#endregion




Get-AzureRmAutomationModule -Name LWINConfigs -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName 



$Config = Import-AzureRmAutomationDscConfiguration -SourcePath (Get-Item C:\Scripts\Presentations\AzureAutomationDSC\TestConfig.ps1).FullName -AutomationAccountName $AutoAcct.AutomationAccountName -ResourceGroupName $AutoAcct.ResourceGroupName -Description DemoConfiguration -Published -Force 



#Now that our configuration is published, we can compile it.  So let's add our parameters and configuration data:

$Parameters = @{
    
            'DomainName' = 'lwinerd.local'
            'ResourceGroupName' = $AutoAcct.ResourceGroupName
            'AutomationAccountName' = $AutoAcct.AutomationAccountName
            'AdminName' = 'lwinadmin'
    
}

$ConfigData = 
@{
    AllNodes = 
    @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
        },


        @{
            NodeName     = "webServer"
            Role         = "WebServer"
        }
        
        @{
            NodeName = "domainController"
            Role = "domaincontroller"
        }

    )
}



$DSCComp = Start-AzureRmAutomationDscCompilationJob -AutomationAccountName $AutoAcct.AutomationAccountName -ConfigurationName $Config.Name -ConfigurationData $ConfigData -Parameters $Parameters -ResourceGroupName $AutoAcct.ResourceGroupName 

Get-AzureRmAutomationDscCompilationJob -Id $DSCComp.Id -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName 

