function Invoke-DemoVMPrep
{
    param
    (
        [string] $VMName, 
        [string] $GuestOSName, 
        [switch] $FullServer
    ) 
 
    Write-Log $VMName 'Removing old VM'
    get-vm $VMName -ErrorAction SilentlyContinue |
    stop-vm -TurnOff -Force -Passthru |
    remove-vm -Force
    Clear-File "$($VMPath)\$($GuestOSName).vhdx"
    
    Write-Log $VMName 'Creating new differencing disk'
    if ($FullServer) 
    {
        $null = New-VHD -Path "$($VMPath)\$($GuestOSName).vhdx" -ParentPath "$($BaseVHDPath)\VMServerBase.vhdx" -Differencing
    }
 
    else
    {
        $null = New-VHD -Path "$($VMPath)\$($GuestOSName).vhdx" -ParentPath "$($BaseVHDPath)\VMServerBaseCore.vhdx" -Differencing
    }
 
    Write-Log $VMName 'Creating virtual machine'
    new-vm -Name $VMName -MemoryStartupBytes 16GB -SwitchName $virtualSwitchName `
    -Generation 2 -Path "$($VMPath)\" | Set-VM -ProcessorCount 2 
 
    Set-VMFirmware -VMName $VMName -SecureBootTemplate MicrosoftUEFICertificateAuthority
    Set-VMFirmware -Vmname $VMName -EnableSecureBoot off
    Add-VMHardDiskDrive -VMName $VMName -Path "$($VMPath)\$($GuestOSName).vhdx" -ControllerType SCSI
    Write-Log $VMName 'Starting virtual machine'
    Enable-VMIntegrationService -Name 'Guest Service Interface' -VMName $VMName
    start-vm $VMName
}
 
function Create-DemoVM 
{
    param
    (
        [string] $VMName, 
        [string] $GuestOSName, 
        [string] $IPNumber = '0'
    ) 
   
    Wait-PSDirect $VMName -cred $localCred
 
    Invoke-Command -VMName $VMName -Credential $localCred {
        param($IPNumber, $GuestOSName,  $VMName, $domainName, $Subnet)
        if ($IPNumber -ne '0') 
        {
            Write-Output -InputObject "[$($VMName)]:: Setting IP Address to $($Subnet)$($IPNumber)"
            $null = New-NetIPAddress -IPAddress "$($Subnet)$($IPNumber)" -InterfaceAlias 'Ethernet' -PrefixLength 24
            Write-Output -InputObject "[$($VMName)]:: Setting DNS Address"
            Get-DnsClientServerAddress | ForEach-Object -Process {
                Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses "$($Subnet)1"
            }
        }
        Write-Output -InputObject "[$($VMName)]:: Renaming OS to `"$($GuestOSName)`""
        Rename-Computer -NewName $GuestOSName
        Write-Output -InputObject "[$($VMName)]:: Configuring WSMAN Trusted hosts"
        Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "*.$($domainName)" -Force
        Set-Item WSMan:\localhost\client\trustedhosts "$($Subnet)*" -Force -concatenate
        Enable-WSManCredSSP -Role Client -DelegateComputer "*.$($domainName)" -Force
    } -ArgumentList $IPNumber, $GuestOSName, $VMName, $domainName, $Subnet
 
    Restart-DemoVM $VMName
     
    Wait-PSDirect $VMName -cred $localCred
} 






Invoke-DemoVMPrep 'DHCP1-RDS' 'DHCP1-RDS' -FullServer
Invoke-DemoVMPrep 'MGMT1-RDS' 'MGMT1-RDS' -FullServer
Invoke-DemoVMPrep 'RDSH01-RDS' 'RDSH01-RDS' -FullServer
Invoke-DemoVMPrep 'RDSH02-RDS' 'RDSH02-RDS' -FullServer
Invoke-DemoVMPrep 'RDGW01-RDS' 'RDGW01-RDS' -FullServer
Invoke-DemoVMPrep 'RDAPP01-RDS' 'RDAPP01-RDS' -FullServer
Invoke-DemoVMPrep 'DC1-RDS' 'DC1-RDS' -FullServer





 
$VMName = 'DC1-RDS'
$GuestOSName = 'DC1-RDS'
$IPNumber = '1'
 
Create-DemoVM $VMName $GuestOSName $IPNumber
 
Invoke-Command -VMName $VMName -Credential $localCred {
    param($VMName, $domainName, $domainAdminPassword)
 
    Write-Output -InputObject "[$($VMName)]:: Installing AD"
    $null = Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    Write-Output -InputObject "[$($VMName)]:: Enabling Active Directory and promoting to domain controller"
    Install-ADDSForest -DomainName $domainName -InstallDNS -NoDNSonNetwork -NoRebootOnCompletion `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -String $domainAdminPassword -AsPlainText -Force) -confirm:$false
} -ArgumentList $VMName, $domainName, $domainAdminPassword
 
Restart-DemoVM $VMName
 
 
$VMName = 'DHCP1-RDS'
$GuestOSName = 'DHCP1-RDS'
$IPNumber = '3'
 
Create-DemoVM $VMName $GuestOSName $IPNumber
 
Invoke-Command -VMName $VMName -Credential $localCred {
    param($VMName, $domainCred, $domainName)
    Write-Output -InputObject "[$($VMName)]:: Installing DHCP"
    $null = Install-WindowsFeature DHCP -IncludeManagementTools
    Write-Output -InputObject "[$($VMName)]:: Joining domain as `"$($env:computername)`""
    while (!(Test-Connection -ComputerName $domainName -BufferSize 16 -Count 1 -Quiet -ea SilentlyContinue)) 
    {
        Start-Sleep -Seconds 1
    }
    do 
    {
        Add-Computer -DomainName $domainName -Credential $domainCred -ea SilentlyContinue
    }
    until ($?)
} -ArgumentList $VMName, $domainCred, $domainName
 
Restart-DemoVM $VMName
Wait-PSDirect $VMName -cred $domainCred
 
Invoke-Command -VMName $VMName -Credential $domainCred {
    param($VMName, $domainName, $Subnet, $IPNumber)
 
    Write-Output -InputObject "[$($VMName)]:: Waiting for name resolution"
 
    while ((Test-NetConnection -ComputerName $domainName).PingSucceeded -eq $false) 
    {
        Start-Sleep -Seconds 1
    }
 
    Write-Output -InputObject "[$($VMName)]:: Configuring DHCP Server"    
    Set-DhcpServerv4Binding -BindingState $true -InterfaceAlias Ethernet
    Add-DhcpServerv4Scope -Name 'IPv4 Network' -StartRange "$($Subnet)10" -EndRange "$($Subnet)200" -SubnetMask 255.255.255.0
    Set-DhcpServerv4OptionValue -OptionId 6 -value "$($Subnet)1"
    Add-DhcpServerInDC -DnsName "$($env:computername).$($domainName)"
    foreach($i in 1..99) 
    {
        $mac = '00-b5-5d-fe-f6-' + ($i % 100).ToString('00')
        $ip = $Subnet + '1' + ($i % 100).ToString('00')
        $desc = 'Container ' + $i.ToString()
        $scopeID = $Subnet + '0'
        Add-DhcpServerv4Reservation -IPAddress $ip -ClientId $mac -Description $desc -ScopeId $scopeID
    }
} -ArgumentList $VMName, $domainName, $Subnet, $IPNumber
 
Restart-DemoVM $VMName 


Now that I had my configurations started I finished up by running Create-DemoVM on the RDS Farm instances which basically just joined them to the domain and restarted them.

$VMName = 'MGMT1-RDS'
$GuestOSName = 'MGMT1-RDS'
 
Create-DemoVM $VMName $GuestOSName
 
Invoke-Command -VMName $VMName -Credential $localCred {
    param($VMName, $domainCred, $domainName)
    Write-Output -InputObject "[$($VMName)]:: Management tools"
    $null = Install-WindowsFeature RSAT-Clustering, RSAT-Hyper-V-Tools
    Write-Output -InputObject "[$($VMName)]:: Joining domain as `"$($env:computername)`""
    while (!(Test-Connection -ComputerName $domainName -BufferSize 16 -Count 1 -Quiet -ea SilentlyContinue)) 
    {
        Start-Sleep -Seconds 1
    }
    do 
    {
        Add-Computer -DomainName $domainName -Credential $domainCred -ea SilentlyContinue
    }
    until ($?)
} -ArgumentList $VMName, $domainCred, $domainName
 
Restart-DemoVM $VMName
 
$VMName = 'RDSH01-RDS'
$GuestOSName = 'RDSH01-RDS'
 
Create-DemoVM $VMName $GuestOSName
 
Invoke-Command -VMName $VMName -Credential $localCred {
    param($VMName, $domainCred, $domainName)
    Write-Output -InputObject "[$($VMName)]:: Management tools"
   # $null = Install-WindowsFeature RSAT-Clustering, RSAT-Hyper-V-Tools
    Write-Output -InputObject "[$($VMName)]:: Joining domain as `"$($env:computername)`""
    while (!(Test-Connection -ComputerName $domainName -BufferSize 16 -Count 1 -Quiet -ea SilentlyContinue)) 
    {
        Start-Sleep -Seconds 1
    }
    do 
    {
        Add-Computer -DomainName $domainName -Credential $domainCred -ea SilentlyContinue
    }
    until ($?)
} -ArgumentList $VMName, $domainCred, $domainName
 
Restart-DemoVM $VMName
 
$VMName = 'RDSH02-RDS'
$GuestOSName = 'RDSH02-RDS'
 
 
Create-DemoVM $VMName $GuestOSName
 
Invoke-Command -VMName $VMName -Credential $localCred {
    param($VMName, $domainCred, $domainName)
    Write-Output -InputObject "[$($VMName)]:: Management tools"
    #$null = Install-WindowsFeature RSAT-Clustering, RSAT-Hyper-V-Tools
    Write-Output -InputObject "[$($VMName)]:: Joining domain as `"$($env:computername)`""
    while (!(Test-Connection -ComputerName $domainName -BufferSize 16 -Count 1 -Quiet -ea SilentlyContinue)) 
    {
        Start-Sleep -Seconds 1
    }
    do 
    {
        Add-Computer -DomainName $domainName -Credential $domainCred -ea SilentlyContinue
    }
    until ($?)
} -ArgumentList $VMName, $domainCred, $domainName
 
Restart-DemoVM $VMName
 
$VMName = 'RDGW01-RDS'
$GuestOSName = 'RDGW01-RDS'
 
Create-DemoVM $VMName $GuestOSName
 
Invoke-Command -VMName $VMName -Credential $localCred {
    param($VMName, $domainCred, $domainName)
    Write-Output -InputObject "[$($VMName)]:: Management tools"
    #$null = Install-WindowsFeature RSAT-Clustering, RSAT-Hyper-V-Tools
    Write-Output -InputObject "[$($VMName)]:: Joining domain as `"$($env:computername)`""
    while (!(Test-Connection -ComputerName $domainName -BufferSize 16 -Count 1 -Quiet -ea SilentlyContinue)) 
    {
        Start-Sleep -Seconds 1
    }
    do 
    {
        Add-Computer -DomainName $domainName -Credential $domainCred -ea SilentlyContinue
    }
    until ($?)
} -ArgumentList $VMName, $domainCred, $domainName
 
Restart-DemoVM $VMName
 
$VMName = 'RDAPP01-RDS'
$GuestOSName = 'RDAPP01-RDS'
 
Create-DemoVM $VMName $GuestOSName
 
Invoke-Command -VMName $VMName -Credential $localCred {
    param($VMName, $domainCred, $domainName)
    Write-Output -InputObject "[$($VMName)]:: Management tools"
    $null = Install-WindowsFeature RSAT-Clustering, RSAT-Hyper-V-Tools
    Write-Output -InputObject "[$($VMName)]:: Joining domain as `"$($env:computername)`""
    while (!(Test-Connection -ComputerName $domainName -BufferSize 16 -Count 1 -Quiet -ea SilentlyContinue)) 
    {
        Start-Sleep -Seconds 1
    }
    do
    {
        Add-Computer -DomainName $domainName -Credential $domainCred -ea SilentlyContinue
    }
    until ($?)
} -ArgumentList $VMName, $domainCred, $domainName
 
Restart-DemoVM $VMName 





######################################

Find-Module xRemoteDesktopSessionHost | Install-Module 


param ( 
[string]$brokerFQDN, 
[string]$webFQDN, 
[string]$collectionName, 
[string]$collectionDescription 
) 
  
$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName 
  
if (!$collectionName) {$collectionName = "DK Collection"} 
if (!$collectionDescription) {$collectionDescription = "Remote Desktop instance for accessing an isolated network environment."} 
  
Configuration RemoteDesktopSessionHost 
{ 
    param 
    ( 
          
        # Connection Broker Name 
        [Parameter(Mandatory)] 
        [String]$collectionName, 
  
        # Connection Broker Description 
        [Parameter(Mandatory)] 
        [String]$collectionDescription, 
  
        # Connection Broker Node Name 
        [String]$connectionBroker, 
  
        # Web Access Node Name 
        [String]$webAccessServer 
    ) 
    Import-DscResource -Module xRemoteDesktopSessionHost 
    if (!$connectionBroker) {$connectionBroker = $localhost} 
    if (!$connectionWebAccessServer) {$webAccessServer = $localhost} 
  
    Node "localhost" 
    { 
  
        LocalConfigurationManager 
        { 
            RebootNodeIfNeeded = $true 
        } 
  
        WindowsFeature Remote-Desktop-Services 
        { 
            Ensure = "Present" 
            Name = "Remote-Desktop-Services" 
        } 
  
        WindowsFeature RDS-RD-Server 
        { 
            Ensure = "Present" 
            Name = "RDS-RD-Server" 
        } 
  
        WindowsFeature Desktop-Experience 
        { 
            Ensure = "Present" 
            Name = "Desktop-Experience" 
        } 
  
        WindowsFeature RSAT-RDS-Tools 
        { 
            Ensure = "Present" 
            Name = "RSAT-RDS-Tools" 
            IncludeAllSubFeature = $true 
        } 
  
        if ($localhost -eq $connectionBroker) { 
            WindowsFeature RDS-Connection-Broker 
            { 
                Ensure = "Present" 
                Name = "RDS-Connection-Broker" 
            } 
        } 
  
        if ($localhost -eq $webAccessServer) { 
            WindowsFeature RDS-Web-Access 
            { 
                Ensure = "Present" 
                Name = "RDS-Web-Access" 
            } 
        } 
  
        WindowsFeature RDS-Licensing 
        { 
            Ensure = "Present" 
            Name = "RDS-Licensing" 
        } 
    
        xRDSessionDeployment Deployment 
        { 
            SessionHost = $localhost 
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost} 
            WebAccessServer = if ($WebAccessServer) {$WebAccessServer} else {$localhost} 
            DependsOn = "[WindowsFeature]Remote-Desktop-Services", "[WindowsFeature]RDS-RD-Server" 
        } 
  
        xRDSessionCollection Collection 
        { 
            CollectionName = $collectionName 
            CollectionDescription = $collectionDescription 
            SessionHost = $localhost 
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost} 
            DependsOn = "[xRDSessionDeployment]Deployment" 
        } 
        xRDSessionCollectionConfiguration CollectionConfiguration 
        { 
        CollectionName = $collectionName 
        CollectionDescription = $collectionDescription 
        ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}         
        TemporaryFoldersDeletedOnExit = $false 
        SecurityLayer = "SSL" 
        DependsOn = "[xRDSessionCollection]Collection" 
        } 
        xRDRemoteApp Calc 
        { 
        CollectionName = $collectionName 
        DisplayName = "Calculator" 
        FilePath = "C:\Windows\System32\calc.exe" 
        Alias = "calc" 
        DependsOn = "[xRDSessionCollection]Collection" 
        } 
        xRDRemoteApp Mstsc 
        { 
        CollectionName = $collectionName 
        DisplayName = "Remote Desktop" 
        FilePath = "C:\Windows\System32\mstsc.exe" 
        Alias = "mstsc" 
        DependsOn = "[xRDSessionCollection]Collection" 
        } 
 
        xRDRemoteApp WordPad 
        { 
        CollectionName = $collectionName 
        DisplayName = "WordPad" 
        FilePath = "C:\Program Files\Windows NT\Accessories\wordpad.exe" 
        Alias = "wordpad" 
        DependsOn = "[xRDSessionCollection]Collection" 
        } 
        xRDRemoteApp CMD
        { 
        CollectionName = $collectionName 
        DisplayName = "CMD" 
        FilePath = "C:\windows\system32\cmd.exe" 
        Alias = "cmd" 
        DependsOn = "[xRDSessionCollection]Collection" 
        } 
    } 
} 
  
write-verbose "Creating configuration with parameter values:" 
write-verbose "Collection Name: $collectionName" 
write-verbose "Collection Description: $collectionDescription" 
write-verbose "Connection Broker: $brokerFQDN" 
write-verbose "Web Access Server: $webFQDN" 
  
RemoteDesktopSessionHost -collectionName $collectionName -collectionDescription $collectionDescription -connectionBroker $brokerFQDN -webAccessServer $webFQDN -OutputPath .\RDSDSC\ 
  
Set-DscLocalConfigurationManager -verbose -path .\RDSDSC\ 
  
Start-DscConfiguration -wait -force -verbose -path .\RDSDSC\ 

