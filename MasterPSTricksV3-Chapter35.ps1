Function Set-AzureRmNSGMaliciousRule {

    [cmdletbinding()]

    Param(

        [Parameter(Mandatory=$true)][string]$ComputerName,
        [Parameter(Mandatory=$true)][string]$IPAddress


    )


    $ResGroup = (Get-AzureRmResource).where({$PSItem.Name -eq $Sys})
    $VM = Get-AzureRmVM -ResourceGroupName $ResGroup.ResourceGroupName -Name $Sys

    $VmNsg = (Get-AzureRmNetworkSecurityGroup -ResourceGroupName $VM.ResourceGroupName).where({$PSItem.NetworkInterfaces.Id -eq $VM.NetworkProfile.NetworkInterfaces.Id})

    $Priority = ($VmNsg.SecurityRules) | Where-Object -Property Priority -LT 200 | Select-Object -Last 1

    If ($Priority -eq $null){

        $Pri = 100

    }
    Else {

        $Pri = ($Priority + 1)

    }



    $Name = ('BlockedIP_' + $IPAddress)



    $NSGArgs = @{

        Name = $Name
        Description = ('Malicious traffic from ' + $IPAddress)
        Protocol = '*'
        SourcePortRange = '*'
        DestinationPortRange = '*'
        SourceAddressPrefix = $IPAddress
        DestinationAddressPrefix = '*'
        Access = 'Deny'
        Direction = 'Inbound'
        Priority = $Pri

    }


    $VmNsg | Add-AzureRmNetworkSecurityRuleConfig @NSGArgs | Set-AzureRmNetworkSecurityGroup
}




    Param(

        [Parameter(ParameterSetName='ConsoleInput')][string]$ComputerName,
        [Parameter(ParameterSetName='ConsoleInput')][string]$MaliciousIP,
        [Parameter(ParameterSetName='WebhookInput')][object]$WebhookData


    )




    
     If($PSCmdlet.ParameterSetName -eq 'WebhookInput'){

        $SearchResults = (ConvertFrom-Json $WebhookData.RequestBody).SearchResults.value

        Write-Output ("Target computer is " + $SearchResults.Computer)
        Write-Output ("Malicious IP is " + $SearchResults.RemoteIP)

        $ComputerName = (($SearchResults.Computer).split(' ') | Select-Object -First 1)
        $MaliciousIP = (($SearchResults.RemoteIP).split(' ') | Select-Object -First 1)

    }


    If ($ComputerName -like "*.*"){

        $Sys = $ComputerName.Split('.') | Select-Object -First 1

    }
    Else {
        $Sys = $ComputerName
    }
 




     Param(

    [Parameter(Mandatory=$true)]
    [object]$WebhookData

)


$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

Set-AzureRmNSGMaliciousRule -WebHookData $WebhookData 


#Now, in a few minutes, our runbook should trigger and we can monitor the result.

$Job = (Get-AzureRmAutomationJob -RunbookName WebhookNSGRule -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName)
$Job[0] | Select-Object -Property * 




#We can start digging into the outputs of the runbook after completion to gather a little more data.

$Job = (Get-AzureRmAutomationJob -RunbookName WebhookNSGRule -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName)

$JobOut = Get-AzureRmAutomationJobOutput -Id $Job[0].JobId -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName

ForEach ($JobCheck in $JobOut){
    
    $JobCheck.Summary
}

ForEach ($JobCheck in $JobOut){
    
    $JobCheck.Summary
} 



#And now if I check against my system, we will see that OMS is auto-generating rules for us!

$VM = (Get-AzureRmResource).where({$PSItem.Name -like 'server1'})
$Machine = Get-AzureRmVM -ResourceGroupName $VM[0].ResourceGroupName -Name $VM[0].Name
$NSG = (Get-AzureRmNetworkSecurityGroup -ResourceGroupName $Machine.ResourceGroupName).where({$PSItem.NetworkInterfaces.Id -eq $Machine.NetworkProfile.NetworkInterfaces.Id})
(Get-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG[0]).where({$PSItem.Name -like "BlockedIP_*"}) 







