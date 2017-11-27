
powershell.exe -file WindowsUpdatesReport.ps1 -email -From IT@Testcompany.com -To mickpletcher@testcompany.com -SMTPServer smtp.testcompany.com 


#https://github.com/MicksITBlogs/PowerShell/blob/master/WindowsUpdatesReport.ps1

[CmdletBinding()]  
 param  
 (  
      [ValidateNotNullOrEmpty()][string]$OutputFile = 'WindowsUpdatesReport.csv',  
      [ValidateNotNullOrEmpty()][string]$ExclusionsFile = 'Exclusions.txt',  
      [switch]$Email,  
      [string]$From,  
      [string]$To,  
      [string]$SMTPServer,  
      [string]$Subject = 'Windows Updates Build Report',  
      [string]$Body = "List of windows updates installed during the build process"  
 )  
   
 function Get-RelativePath {  
        
      [CmdletBinding()][OutputType([string])]  
      param ()  
        
      $Path = (split-path $SCRIPT:MyInvocation.MyCommand.Path -parent) + "\"  
      Return $Path  
 }  
   
 function Remove-OutputFile {  
        
      [CmdletBinding()]  
      param ()  
        
      #Get the path this script is executing from  
      $RelativePath = Get-RelativePath  
      #Define location of the output file  
      $File = $RelativePath + $OutputFile  
      If ((Test-Path -Path $File) -eq $true) {  
           Remove-Item -Path $File -Force  
      }  
 }  
   
 function Get-Updates {  
        
      [CmdletBinding()][OutputType([array])]  
      param ()  
        
      $UpdateArray = @()  
      #Get the path this script is executing from  
      $RelativePath = Get-RelativePath  
      #File containing a list of exclusions  
      $ExclusionsFile = $RelativePath + $ExclusionsFile  
      #Get list of exclusions from exclusions file  
      $Exclusions = Get-Content -Path $ExclusionsFile  
      #Locate the ZTIWindowsUpdate.log file  
      $FileName = Get-ChildItem -Path $env:HOMEDRIVE"\minint" -filter ztiwindowsupdate.log -recurse  
      #Get list of all installed updates except for Windows Malicious Software Removal Tool, Definition Update for Windows Defender, and Definition Update for Microsoft Endpoint Protection  
      $FileContent = Get-Content -Path $FileName.FullName | Where-Object { ($_ -like "*INSTALL*") } | Where-Object { $_ -notlike "*Windows Defender*" } | Where-Object { $_ -notlike "*Endpoint Protection*" } | Where-Object { $_ -notlike "*Windows Malicious Software Removal Tool*" } | Where-Object { $_ -notlike "*Dell*" } | Where-Object { $_ -notlike $Exclusions }  
      #Filter out all unnecessary lines  
      $Updates = (($FileContent -replace (" - ", "~")).split("~") | where-object { ($_ -notlike "*LOG*INSTALL*") -and ($_ -notlike "*ZTIWindowsUpdate*") -and ($_ -notlike "*-*-*-*-*") })  
      foreach ($Update in $Updates) {  
           #Create object  
           $Object = New-Object -TypeName System.Management.Automation.PSObject  
           #Add KB article number to object  
           $Object | Add-Member -MemberType NoteProperty -Name KBArticle -Value ($Update.split("(")[1]).split(")")[0].Trim()  
           #Add description of KB article to object  
           $Description = $Update.split("(")[0]  
           $Description = $Description -replace (",", " ")  
           $Object | Add-Member -MemberType NoteProperty -Name Description -Value $Description  
           #Add the object to the array  
           $UpdateArray += $Object  
      }  
      If ($UpdateArray -ne $null) {  
           $UpdateArray = $UpdateArray | Sort-Object -Property KBArticle  
           #Define file to write the report to  
           $OutputFile = $RelativePath + $OutputFile  
           $UpdateArray | Export-Csv -Path $OutputFile -NoTypeInformation -NoClobber  
      }  
      Return $UpdateArray  
 }  
   
 Clear-Host  
 #Delete the old report file  
 Remove-OutputFile  
 #Get list of installed updates  
 Get-Updates  
 If ($Email.IsPresent) {  
      $RelativePath = Get-RelativePath  
      $Attachment = $RelativePath + $OutputFile  
      #Email Updates  
      Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Attachments $Attachment  
 }  
