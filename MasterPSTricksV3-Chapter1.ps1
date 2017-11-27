﻿install-module PSFTP -Force
Import-Module -Name PSFTP
$username = “anonymous”
$password = “anonymous”
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

Set-FTPConnection -Credentials $Cred -Server ftp://ftp.supermicro.com -Session DownloadingDrivers -UsePassive
$Session = Get-FTPConnection -Session DownloadingDrivers

Get-FTPItem -Session $Session -Path /driver/SATA/Intel_PCH_RAID_Romley_RSTE/Management/5.0.0.2192/IATA_CD.exe -LocalPath “c:\post-install\SuperMicroDrivers” -RecreateFolders -Overwrite
Get-FTPItem -Session $Session -Path /driver/VGA/ASPEED/v1.03.zip -LocalPath “c:\post-install\SuperMicroDrivers” -RecreateFolders -Overwrite
Get-FTPItem -Session $Session -Path /driver/SATA/Intel_PCH_RAID_Romley_RSTE/Windows/5.0.0.2192/Win.zip -RecreateFolders -Overwrite
Get-FTPItem -Session $Session -Path /driver/LAN/Intel/PRO_v22.4.zip -RecreateFolders -Overwrite
Get-FTPItem -Session $Session -Path /driver/SATA/Intel_PCH_RAID_Romley_RSTE/Management/5.0.0.2192/rste_5.0.0.2192_cli.zip -LocalPath “c:\post-install\SuperMicroDrivers” -RecreateFolders -Overwrite
Get-FTPItem -Session $Session -Path /driver/SATA/Intel_PCH_RAID_Romley_RSTE/Management/5.0.0.2192/rste_5.0.0.2192_install.zip -LocalPath “c:\post-install\SuperMicroDrivers” -RecreateFolders -Overwrite
Get-FTPItem -Session $Session -Path /driver/SATA/Intel_PCH_RAID_Romley_RSTE/Windows/5.0.0.2192/rste_5.0.0.2192_f6-drivers.zip -LocalPath