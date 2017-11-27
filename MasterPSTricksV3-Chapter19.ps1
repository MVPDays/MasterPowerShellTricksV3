#In our example, let’s say that you have a CSV with two columns “ComputerName” and “IPAddress” and you want to add a column for “Port3389Open” to see if the port for RDP is open or not. It’s only a few lines of code from being done. 

$servers = Import-Csv C:\Temp\demo\servers.csv 

$servers 


$servers = $servers | Select-Object -Property *, @{label = 'Port3389Open'; expression = {(Test-NetConnection -ComputerName $_.Name -Port 3389).TcpTestSucceeded}}  


$servers | Export-Csv -Path c:\temp\demo\servers-and-port-data.csv -NoTypeInformation  
$Servers 




