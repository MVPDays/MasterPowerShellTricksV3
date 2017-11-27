
$user = $Credential.Username 
$pass = $Credential.GetNetworkCredential().Password 
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass))) 
     
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]" 
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo)) 
$headers.Add('Accept','application/json') 
     
$uriGetIncident = "https://$SubDomain.service-now.com/api/now/table/incident?sysparm_query=number%3D$SNIncidentNumber&sysparm_fields=&sysparm_limit=1" 
     
$responseGetIncident = Invoke-WebRequest -Headers $headers -Method "GET" -Uri $uriGetIncident  
$resultGetIncident = ($responseGetIncident.Content | ConvertFrom-Json).Result  



#Assuming I already created a credential object named $Credential to hold my ServiceNow creds, I can add do some encoding to assemble them in a way that I can add them to the header of the request I’m about to make. I’m doing that on the first three lines. 
#On lines 5 – 7, I’m constructing those headers. So far, I’m following all the PowerShell examples given in the ServiceNow documentation. 
#Line 9 is where I create the URI for the incident get request. You’ll notice I have a variable for both the subdomain (will be unique for your instance of ServiceNow) and the ServiceNow incident number. 
#Lines 10 and 11 get the incident and parse the results of my request. 
#Now I can add some work notes. 

$workNotesBody = @" 
{"work_notes":"$Message"} 
"@ 
     
$uriPatchIncident = "https://$SubDomain.service-now.com/api/now/table/incident/$($resultGetIncident.sys_id)" 
$null = Invoke-WebRequest -Headers $headers -Method "PATCH" -Uri $uriPatchIncident -body $workNotesBody  



