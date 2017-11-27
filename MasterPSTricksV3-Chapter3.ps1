param ( 
    $VirtualCenter = "VirtualCenter.corp.local", 
    $smtpServer = "smtp1.corp.local", 
    $smtpFrom = "vmware@corp.local", 
    $smtpTo = "arafuse@corp.local", 
    $smtpSubject = "VMware Snapshots", 
    $SnapShotsOlderThanXDays = 14 
)  

Get-Module -ListAvailable VMware.VimAutomation.* | Import-Module -ErrorAction SilentlyContinue 
If ($global:DefaultVIServer) { 
    Disconnect-VIServer * -Confirm:$false -ErrorAction SilentlyContinue 
} 
$VCServer = Connect-VIServer -Server $VirtualCenter  


$VmsWithAllowedSnaps = @(".*SnappyImage.*") 
$LogEntriesPerVM = 4000 
  
$VMs = Get-VM 
Foreach ($VmsWithAllowedSnap in $VmsWithAllowedSnaps) { 
    $VMs = $VMs | Where {$_.Name -notmatch $VmsWithAllowedSnap} 
} 
$SnapShots = $VMs | Get-Snapshot 
  
$date = Get-Date 
$measure = Measure-Command {  
    $report = $Snapshots | Select-Object VM, Name, @{Name="User"; Expression = { (Get-VIEvent -Entity $_.VM -MaxSamples $LogEntriesPerVM -Start $_.Created.AddSeconds(-10) | Where {$_.Info.DescriptionId -eq "VirtualMachine.createSnapshot"} | Sort-Object CreatedTime | Select-Object -First 1).UserName}}, Created, @{Name="Days Old"; E={$_.Created - }}, Description | Sort-Object -Property "Created" 
} 
#($measure).TotalMinutes 
  
$report = $report | Where {($_.Created).AddDays([int]$SnapShotsOlderThanXDays) -lt (Get-Date)}   


$head = @" 
<title>Snapshot Daily/Weekly Report</title> 
<style type="text/css"> 
  body { background-color: white; }  
  table { border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse; } 
  th {border-width: 1px; padding: 0px; border-style: solid; border-color: black; background-color:thistle } 
  td {border-width: 1px ;padding: 0px; border-style: solid; border-color: black; } 
  tr:nth-child(odd) { background-color:#d3d3d3; }  
  tr:nth-child(even) { background-color:white; } 
</style> 
"@ 
  
$postContent = @" 
<p>Number of Snapshots: $($report.count)</p> 
<p>Generated on $($ENV:COMPUTERNAME)</p> 
"@ 
  
#Send Email Report 
$date = Get-Date 
$message = New-Object System.Net.Mail.MailMessage $smtpFrom, $smtpTo 
$message.Subject = $smtpSubject 
$message.IsBodyHTML = $true 
  
$SnapshotReportHTML = $report | ConvertTo-Html -Head $head -PreContent "Report Date: $date" -PostContent $PostContent 
$message.Body = $SnapshotReportHTML | Out-String 
$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
$smtp.Send($message)  
