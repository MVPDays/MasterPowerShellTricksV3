<#>
In PowerShell, when outputting data to the console, it’s typically either organized into a table or a list. You can force output to take either of these forms using the Format-Table and the Format-List cmdlets, and people who write PowerShell cmdlets and modules can take special steps to make sure their output is formatted as they desire. But, when no developer has specifically asked for a formatted output, how does PowerShell choose to display a table or a list? 

The answer is actually pretty simple and I’m going to highlight it with an example. Take a look at the following piece of code. 

</#>

get-wmiobject -class win32_operatingsystem | select pscomputername,caption,osarch*,registereduser 


#I used Get-WmiObject to get some information about my operating system. I selected four properties and PowerShell decided to display a table. Now, let’s add another property to return. 

get-wmiobject -class win32_operatingsystem | select pscomputername,caption,osarch*,registereduser,version

<#>Whoa, now we get a list. What gives? 
Well here’s how PowerShell decides, by default, whether to display a list or table: 
·	If showing four or fewer properties, show a table 
·	If showing five or more properties, show a list 
That’s it, that’s how PowerShell decides by default whether to show you a list or table. 
</#>