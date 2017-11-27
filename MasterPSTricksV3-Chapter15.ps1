#To use Get-SmbShare on a remote computer, you’ll create a new CIM session. 

$ComputerName = 'tccalst01'
New-CimSession -ComputerName $computername -Credential $creds  

#Then you can pass that CIM session to Get-SmbShare

Get-SmbShare -CimSession $(get-cimsession -id 1)  

#Well, luckily for those older servers, you can use Get-WmiObject to retrieve this information. 

$oldcomp = 'tccalst01'
Get-WmiObject -Class win32_share -ComputerName $oldComp -Credential $creds 
