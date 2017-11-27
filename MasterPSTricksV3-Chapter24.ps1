#Let’s say you’re using Get-CimInstance to get information about the operating system. You might do something like this. 

Get-CimInstance -ClassName win32_operatingsystem 

Get-CimInstance -ClassName win32_operatingsystem | get-member 


$osInfo = Get-CimInstance -ClassName win32_operatingsystem 

$osInfo.GetHashCode() 
