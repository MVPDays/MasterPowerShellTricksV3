#Let me clarify with an example. If you run the Get-ChildItem cmdlet, you’ll get a bit of information back about all the files in whichever directory you specified. 

Get-ChildItem c:\temp\demo 
Get-ChildItem c:\temp\demo | Select-Object -Property *  

Get-ChildItem c:\temp\demo | Select-Object -Property Name, Attributes, IsReadOnly  