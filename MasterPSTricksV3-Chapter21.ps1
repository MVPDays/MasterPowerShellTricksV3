#Well, it involves knowing about what your host actually does. What ports are supposed to be open? Once you know that, you can use Test-NetConnection in PowerShell to check if the port is open and responding on the host you’re interested in. 

$Nodes = 'tccalst01','tccaldc04'
$nodes
$Nodes | % {Test-NetConnection -Computername $_.ToString() -Port 3389} 
