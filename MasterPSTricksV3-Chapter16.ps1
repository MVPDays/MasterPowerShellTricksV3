#Ever wanted to work with ServiceNow via PowerShell?   Let me show you some basics like fetching a user.
#Let’s jump into some code first and I’ll break down what I’m doing. 


$user = $Credential.Username 
$pass = $Credential.GetNetworkCredential().Password 
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass))) 
  
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]" 
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo)) 
$headers.Add('Accept','application/json') 
  
$uri = "https://$SubscriptionSubDomain.service-now.com/api/now/v1/table/sys_user?sysparm_query=user_name=$Username" 
  
$response = Invoke-WebRequest -Headers $headers -Method "GET" -Uri $uri  
$result = ($response.Content | ConvertFrom-Json).Result  

