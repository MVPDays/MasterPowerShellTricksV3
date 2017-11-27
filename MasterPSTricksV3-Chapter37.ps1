Get-AzureRmAutomationDscNodeConfiguration -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName -ConfigurationName TestConfig



$TargetResGroup = 'nrdtste'
$VMName = 'ctrxeusdbnp01'

$VM = Get-AzureRmVM -ResourceGroupName $TargetResGroup -Name $VMName 





$DSCLCMConfig = @{

    'ConfigurationMode' = 'ApplyAndAutocorrect'
    'RebootNodeIfNeeded' = $true
    'ActionAfterReboot' = 'ContinueConfiguration'

} 



#Once we have all of this, we can now go ahead and register our target node in Automation DSC using the Register-AzureRmAutomationDscNode command.

Register-AzureRmAutomationDscNode -AzureVMName $VM.Name -AzureVMResourceGroup $VM.ResourceGroupName -AzureVMLocation $VM.Location -AutomationAccountName $AutoAcct.AutomationAccountName -ResourceGroupName $AutoAcct.ResourceGroupName @DSCLCMConfig 




$Configuration = Get-AzureRmAutomationDscNodeConfiguration -AutomationAccountName $AutoAcct.AutomationAccountName -ResourceGroupName $AutoAcct.ResourceGroupName -Name 'CompositeConfig.webServer'

$TargetNode = Get-AzureRmAutomationDscNode -Name $VM.Name -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName
Set-AzureRmAutomationDscNode -Id $TargetNode.Id -NodeConfigurationName $Configuration.Name -AutomationAccountName $AutoAcct.AutomationAccountName -ResourceGroupName $AutoAcct.ResourceGroupName -Verbose -Force



Get-AzureRmAutomationDscNodeReport -NodeId $TargetNode.Id -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName -Latest 







#Get the resourceId of the automation account.
$AutoAcctResource = Find-AzureRmResource -ResourceType "Microsoft.Automation/automationAccounts" -ResourceNameContains 'testautoaccteastus2'

#Get the resourceId of the Log Analytics Workspace
$LogAnalyticsResource = Find-AzureRmResource -ResourceType "Microsoft.OperationalInsights/workspaces" -ResourceNameContains 'LWINerd' 


#Then we can use those resourceIds to pass to Set-AzureRmDiagnosticSetting and specify our DSCNodeStatus category.


Set-AzureRmDiagnosticSetting -ResourceId $AutoAcctResource.ResourceId -WorkspaceId $LogAnalyticsResource.ResourceId -Enabled $true -Categories "DscNodeStatus" -Verbose 



#Then you'll get a return similar to this:

Set-AzureRmDiagnosticSetting -ResourceId $AutoAcctResource.ResourceId -WorkspaceId $LogAnalyticsResource.ResourceId -Enabled $true -Categories "D
scNodeStatus" -Verbose


