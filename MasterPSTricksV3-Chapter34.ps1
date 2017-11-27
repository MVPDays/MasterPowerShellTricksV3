
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






Param (

    [Parameters()][object]$WebHookData

) 



   $WebhookData.WebhookName
   $WebhookData.RequestHeader
   $WebhookData.RequestBody 

#Let's configure our runbook to display the incoming data to examine what we have to play with.

$SearchResults = (ConvertFrom-Json $WebhookData.RequestBody).SearchResults.value

$SearchResults 






Import-AzureRmAutomationRunbook -Path 'C:\Scripts\Presentations\OMSAutomation\ExampleRunbookScript.ps1' -Name WebhookNSGRule -Type PowerShell -ResourceGroupName $AutoAcct.ResourceGroupName -AutomationAccountName $AutoAcct.AutomationAccountName -Published 


<#>
Canned Query:
MaliciousIP=* AND (RemoteIPCountry=* OR MaliciousIPCountry=*) AND (((Type=WireData AND Direction=Outbound) OR (Type=WindowsFirewall AND CommunicationDirection=SEND) OR (Type=CommonSecurityLog AND CommunicationDirection=Outbound)) OR (Type=W3CIISLog OR Type=DnsEvents OR (Type = WireData AND Direction!= Outbound) OR (Type=WindowsFirewall AND CommunicationDirection!=SEND) OR (Type = CommonSecurityLog AND CommunicationDirection!= Outbound))) (RemoteIPCountry="People's Republic of China" OR MaliciousIPCountry="People's Republic of China")

Modified Query:
MaliciousIP=* AND (RemoteIPCountry=* OR MaliciousIPCountry=*) AND (((Type=WireData AND Direction=Outbound) OR (Type=WindowsFirewall AND CommunicationDirection=SEND) OR (Type=CommonSecurityLog AND CommunicationDirection=Outbound)) OR (Type=W3CIISLog OR Type=DnsEvents OR (Type = WireData AND Direction!= Outbound) OR (Type=WindowsFirewall AND CommunicationDirection!=SEND) OR (Type = CommonSecurityLog AND CommunicationDirection!= Outbound)))

</#>


