$SccmServer = "SCCM01" 
$PathToSCCMModule = "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" 
  
$MemberName = $env:COMPUTERNAME 
$SCCMSession = New-PSSession -ComputerName $SccmServer 
Invoke-Command -Session $SccmSession -ArgumentList @($PathToSCCMModule, $MemberName) -ScriptBlock { 
    Param ( 
        [string]$PathToSCCMModule, 
        [string]$MemberName 
    ) 
    Import-Module $PathToSCCMModule -ErrorAction SilentlyContinue 
    $SccmSite = (Get-PSDrive -PSProvider CMSite | Sort-Object -Property Name | Select-Object -First 1).Name 
    Set-Location "$($SccmSite):" 
  
    $ResourceID = (Get-CMDevice -Name $MemberName).ResourceID 
    If ($ResourceID) { 
        Add-CMDeviceCollectionDirectMembershipRule -CollectionName "SCEP - Servers" -ResourceId $ResourceID 
    } 
}  
