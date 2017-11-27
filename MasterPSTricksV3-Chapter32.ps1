﻿
  [CmdletBinding()]  
 param ()  
   
 function Uninstall-MSIByName {  
        
      [CmdletBinding()]  
      param  
      (  
           [ValidateNotNullOrEmpty()][String]$ApplicationName,  
           [ValidateNotNullOrEmpty()][String]$Switches  
      )  
        
      #MSIEXEC.EXE  
      $Executable = $Env:windir + "\system32\msiexec.exe"  
      #Get list of all Add/Remove Programs for 32-Bit and 64-Bit  
      $Uninstall = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -Recurse -ErrorAction SilentlyContinue  
      If (((Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture) -eq "64-Bit") {  
           $Uninstall += Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall -Recurse -ErrorAction SilentlyContinue  
      }  
      #Find the registry containing the application name specified in $ApplicationName  
      $Key = $uninstall | foreach-object { Get-ItemProperty REGISTRY::$_ } | where-object { $_.DisplayName -like "*$ApplicationName*" }  
      If ($Key -ne $null) {  
           Write-Host "Uninstall"$Key.DisplayName"....." -NoNewline  
           #Define msiexec.exe parameters to use with the uninstall  
           $Parameters = "/x " + $Key.PSChildName + [char]32 + $Switches  
           #Execute the uninstall of the MSI  
           $ErrCode = (Start-Process -FilePath $Executable -ArgumentList $Parameters -Wait -Passthru).ExitCode  
           #Return the success/failure to the display  
           If (($ErrCode -eq 0) -or ($ErrCode -eq 3010) -or ($ErrCode -eq 1605)) {  
                Write-Host "Success" -ForegroundColor Yellow  
           } else {  
                Write-Host "Failed with error code "$ErrCode -ForegroundColor Red  
           }  
      }  
 }  
   
 Clear-Host  
 Uninstall-MSIByName -ApplicationName "Cisco Jabber" -Switches "/qb- /norestart"  

