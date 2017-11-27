#Powershell SET commands Sets
  
Set-MlnxDriverCoreSetting
Set-MlnxPCIDevicePortTypeSetting
Set-MlnxPCIDeviceSriovSetting
  
  
#Powershell GET commands Sets
  
Get-MlnxDriver
Get-MlnxFirmware
Get-MlnxIBPort
Get-MlnxNetAdapter
Get-MlnxPCIDevice
Get-MlnxSoftware
  
#Get-MlnxDriver Command Set
  
Get-MlnxDriverCapabilities
Get-MlnxDriverCoreCapabilities
Get-MlnxDriverCoreSetting
Get-MlnxDriverService
Get-MlnxDriverSetting
 
 
Get-MlnxDriverCapabilities |FL
Get-MlnxDriverCoreCapabilities |FL
Get-MlnxDriverCoreSetting | FL
Get-MlnxFirmwareIdentity | FL
Get-MlnxIBPort
Get-MlnxIBPortCounters | FL
Get-MlnxNetAdapter | FL
Get-MlnxNetAdapterEcnSetting | FL
Get-MlnxNetAdapterFlowControlSetting | FL
Get-MlnxNetAdapterRoceSetting | FL
Get-MlnxNetAdapterSetting |FL
Get-MLNXPCIDevice | fl
Get-MLNXPCIDeviceCapabilities | fl
Get-MlnxPCIDevicePortTypeSetting |fl
Get-MlnxPCIDeviceSetting | fl
Get-MlnxSoftwareIdentity 


############################################



$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@
 
$servers = @('S2DNODE1','S2DNODE2')
$resultComputerInfo = Invoke-Command -ComputerName $servers -ScriptBlock { Get-ComputerInfo | Select-Object -Property CSDNSHostName,WindowsEditionId,OSServerLevel,OSUptime,OsFreePhysicalMemory,CSModel,CSManufacturer,CSNumberOfLogicalProcessors,CSNumberofProcessors,HyperVisorPresent }
 
$resultMLNXPCIDevice = Invoke-Command -ComputerName $servers -ScriptBlock { Get-MLNXPCIDevice | Select-Object -Property Systemname,Caption,Description,DeviceID,LastErrorCode,DriverVersion,FirmwareVersion }
 
$resultMlnxPCIDeviceSetting = Invoke-Command -ComputerName $servers -ScriptBlock { Get-MlnxPCIDeviceSetting | Select-Object -Property Systemname,Caption,Description,InstanceID }
 
$resultMLNXPCIDeviceCapabilities = Invoke-Command -ComputerName $servers -ScriptBlock { Get-MLNXPCIDeviceCapabilities | Select-Object -Property Systemname,Caption,Description,PortOneAutoSense,PortOneDefault,PortOneAutoSenseAllowed,PortOneEth,PorttwoIb,PortTwoAutoSenseCap,PortTwoDefault,PortTwoDoSenseAllowed,PortTwoEth }
 
$resultMlnxNetAdapter = Invoke-Command -ComputerName $servers -ScriptBlock { Get-MlnxNetAdapter | Select-Object -Property Systemname,Caption,Description,Name,ErrorDescription,MaxSpeed,MaxTransmissionUnit,AutoSense,FullDuplex,LinkTechnology,PortNumber,DroplessMode }
 
$resultMlnxNetAdapterRoceSetting = Invoke-Command -ComputerName $servers -ScriptBlock { Get-MlnxNetAdapterRoceSetting | Select-Object -Property Systemname,Caption,Description,InterfaceDescription,PortNumber,RoceMode,Enabled }
 
$resultMlnxIBPort = Invoke-Command -ComputerName $servers -ScriptBlock { Get-MlnxIBPort | Select-Object -Property Systemname,Caption,Description,MaxSpeed,PortType,Speed,ActiveMaximumTransmissionUnit,PortNumberSupportedMaximumTransmissionUnit,MaxMsgSize,MaxVls,NumGids,NumPkeys,Transport }
 
$resultMlnxIBPortCounters = Invoke-Command -ComputerName $servers -ScriptBlock { Get-MlnxIBPortCounters | Select-Object -Property Systemname,Caption,Description,StatisticTime,BytesReceived,BytesTransmitted,PacketsReceived,PacketsTransmitted,ExcessiveBufferOverflows,LinkDownCounter,LinterErrorRecoveryCounter,PortRcvErrors }
 
$resultMlnxFirmwareIdentity = Invoke-Command -ComputerName $servers -ScriptBlock { Get-MlnxFirmwareIdentity | Select-Object -Property Caption,Description,Name,Manufacturer,VersionString  }
 
 
ConvertTo-Html -Body "<H1>CheckyourLogs.Net Mellanox Storage Spaces Direct S2D Node Configuration Report </H1><H1> S2D System Information </H3> $($resultComputerInfo | Convertto-Html -Property * -Fragment) <H1> Mellanox Software  </H1> $($resultMLNXPCIDevice | Convertto-Html -Property * -Fragment)) <h1>Mellanox PCI Device Settings</h1> $($resultMLNXPCIDeviceDeviceSetting | Convertto-Html -Property * -Fragment) <H1> Mellanox Device Capabilities </H1> $($resultMLNXPCIDeviceCapabilities | Convertto-Html -Property * -Fragment) <H1> Mellanox NetAdapter Info </H1>$($resultMlnxNetAdapter | Convertto-Html -Property * -Fragment) <H1> Mellanox ROCE Settings </H1> $($resultMlnxNetAdapterRoceSetting | Convertto-Html -Property * -Fragment) <H1> Mellanox IB Port Configuration </H1> $($resultMlnxIBPort | Convertto-Html -Property * -Fragment) <H1> Mellanox IB Port Counters </H1>$($resultMlnxIBPortCounters | Convertto-Html -Property * -Fragment) <H1> Mellanox Adapter Firmware </H1> $($resultMlnxFirmwareIdentity | Convertto-Html -Property * -Fragment)" -Title "Mellanox Adapter Configuraiton" -Head $Header |Out-File mellanoxreport.html 


