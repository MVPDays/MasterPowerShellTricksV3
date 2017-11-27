Function Get-ComputerMemory { 
    $mem = Get-WMIObject -class Win32_PhysicalMemory | 
Measure-Object -Property Capacity -Sum 
    return ($mem.Sum / 1MB); 
}  


Function Get-SQLMaxMemory {  
    $memtotal = Get-ComputerMemory 
    $min_os_mem = 2048 ; 
    if ($memtotal -le $min_os_mem) { 
        Return $null; 
    } 
    if ($memtotal -ge 8192) { 
        $sql_mem = $memtotal - 2048 
    } else { 
        $sql_mem = $memtotal * 0.8 ; 
    } 
    return [int]$sql_mem ;   
}  


Function Set-SQLInstanceMemory { 
    param ( 
        [string]$SQLInstanceName = ".",  
        [int]$maxMem = $null,  
        [int]$minMem = 0 
    ) 
  
    if ($minMem -eq 0) { 
        $minMem = $maxMem 
    } 
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null 
    $srv = New-Object Microsoft.SQLServer.Management.Smo.Server($SQLInstanceName) 
    if ($srv.status) { 
        Write-Host "[Running] Setting Maximum Memory to: $($srv.Configuration.MaxServerMemory.RunValue)" 
        Write-Host "[Running] Setting Minimum Memory to: $($srv.Configuration.MinServerMemory.RunValue)" 
  
        Write-Host "[New] Setting Maximum Memory to: $maxmem" 
        Write-Host "[New] Setting Minimum Memory to: $minmem" 
        $srv.Configuration.MaxServerMemory.ConfigValue = $maxMem 
        $srv.Configuration.MinServerMemory.ConfigValue = $minMem    
        $srv.Configuration.Alter() 
    } 
}  


$MSSQLInstance = "sql01\SQLInstance01" 
Set-SQLInstanceMemory $MSSQLInstance (Get-SQLMaxMemory) 
