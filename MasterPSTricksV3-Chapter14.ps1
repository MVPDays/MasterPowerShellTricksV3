#If you’ve been around PowerShell, you’re used to seeing the pipe character ( | ) used to pass the output from one command into the input of another. What you can do now, kind of, is pass the output of a PowerShell command into the input of a Bash command. Here’s an example. Get ready for this biz. 

Get-ChildItem c:\temp\demo | foreach-object { bash -c "echo $($_.Name) | awk /\.csv/" }  
