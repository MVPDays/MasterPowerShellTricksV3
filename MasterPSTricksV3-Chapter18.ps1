#As you likely know, you can use Get-ChildItem to get all the items in a directory. Did you know, however, that you can have PowerShell quickly count how many files and folders there are? 

(Get-ChildItem -Path c:\temp\).count  


(Get-AdUser -filter "Name -like 'Cristal *'").count  

