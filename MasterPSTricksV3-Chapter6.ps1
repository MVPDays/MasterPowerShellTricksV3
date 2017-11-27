# http://docs.datadoghq.com/api/#embeds 
$url_base = "https://app.datadoghq.com/" 
$api_key = "asdlfk771ja8z8m0980asz8knnn5f9a9" 
$app_key = "x5jaja81jamnz81o85618fcce8a891912387a7f3"  


#Pulling Authenticated Users

#Users 
$url_signature = "api/v1/user" 
$url = $url_base + $url_signature + "?api_key=$api_key" + "&" + "application_key=$app_key" 
$response = Invoke-WebRequest -ContentType "application/json" -Uri $url 
$response.Content | ConvertFrom-Json | Select-Object -ExpandProperty Users  


#Muting a Host

# Mute 
$url_signature = "api/v1/host/MyHostName1/mute" 
$url = $url_base + $url_signature + "?api_key=$api_key" + "&" + "application_key=$app_key" 
$response = Invoke-WebRequest -Uri $url -Method Post 
$response.Content | ConvertFrom-Json  


#Unmuting a Host

# Unmute 
$url_signature = "api/v1/host/WMAPMTSTEST/unmute" 
$url = $url_base + $url_signature + "?api_key=$api_key" + "&" + "application_key=$app_key" 
$response = Invoke-WebRequest -Uri $url -Method Post 
$response.Content | ConvertFrom-Json  

#Display Host/Agent Details

$includeInfo = @( 
    "with_apps=true", 
    "with_sources=true", 
    "with_aliases=true", 
    "with_meta=true", 
    "with_mute_status=true", 
    "with_tags=true" 
) 
  
$metricInfo = @( 
    "metrics=avg", 
    "system.cpu.idle avg", 
    "aws.ec2.cpuutilization avg", 
    "vsphere.cpu.usage avg", 
    "azure.vm.processor_total_pct_user_time avg", 
    "system.cpu.iowait avg", 
    "system.load.norm.15" 
) 
  
$url_query = "" 
$url_signature = "reports/v2/overview" 
$url = $url_base + $url_signature + "?api_key=$api_key" + "&amp;" + "application_key=$app_key" + "&amp;" + "window=3h" + "&amp;" + (($metricInfo -join "%3A") -replace " ", "%2C") + "&amp;" + ($includeInfo -join "&amp;") 
if ($url_query) { 
    $url += "&amp;" + $url_query 
} 
$response = Invoke-WebRequest -Uri $url -Method Get 
$response.Content | ConvertFrom-Json | Select-Object -ExpandProperty rows | Select-Object Host_name,  @{n="Actively_Reporting"; e={$_.has_metrics}}, @{n="Agent_Version"; e={$_.meta.Agent_version}}, @{n="Agent_Branch"; e={($_.meta.gohai | ConvertFrom-Json).gohai | Select-Object -ExpandProperty git_branch}}, @{n="ip"; e={($_.meta.gohai | ConvertFrom-Json).network | Select-Object -ExpandProperty ipaddress}}, @{n="LogicalProcessors"; e={$logical = ($_.meta.gohai | ConvertFrom-Json).cpu | Select-Object -ExpandProperty cpu_logical_processors; $cpu_cores = ($_.meta.gohai | ConvertFrom-Json).cpu | Select-Object -ExpandProperty cpu_cores; ($logical / $cpu_cores) * $logical }} | Sort-Object -Property host_name | ft  


# Event Log Errors
$dateStart = (Get-Date (Get-Date).AddDays(-30) -Uformat %s) -replace "\..*", ""
$dateEnd = (Get-Date (Get-Date).AddDays(0) -Uformat %s) -replace "\..*", ""
$url_signature = "api/v1/events"
 
&nbsp;$EventSearch = @(
    "start=$dateStart",
    "end=$dateEnd"
    "source=Event Viewer" 
)
 
$url = $url_base + $url_signature + "?api_key=$api_key" + "&amp;" + "application_key=$app_key" + "&amp;" + ($EventSearch -join "&amp;")
$response = Invoke-WebRequest -Uri $url -Method Get
 
$response.Content | ConvertFrom-Json | Select-Object -ExpandProperty events | Where {$_.Title -eq "Application/Microsoft-Windows-Folder Redirection" -and $_.Text -like "*redirect folder*"} | Select-Object -Unique -Property Text| fl text
$response.Content | ConvertFrom-Json | Select-Object -ExpandProperty events | Where {$_.Title -eq "System/TermDD"} | Select-Object -Unique -Property Text, Host, @{Name ="Timestamp"; Expression={[TimeZone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($_.date_happened))}} | Group-Object -Property host