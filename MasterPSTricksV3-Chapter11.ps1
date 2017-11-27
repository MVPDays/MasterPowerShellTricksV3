
#Recently, I was helping someone in a forum who was trying to figure out what kind of object their command was returning. They knew about the standard cmdlets people suggest when you’re getting started (Get-Help, Get-Member, and Get-Command), but couldn’t figure out what was coming back from a specific command. 
#In order to make this a more generic example, and to simplify it, let’s approach this differently. Say I have these two objects where one is a string and the other is an array of two strings. 


$thing1 = 'This is an item' 
$thing2 = @('This is another item','This is one more item') 
$thing1; $thing2  

#The third line shows you what you get if you write these out to the screen. 

#It looks like three separate strings, right? Well we should be able to dissect these with Get-Member to get to the bottom of this and identify the types of objects these are. After all, one is a string and the other is an array, right?  

$thing1 | Get-Member 

#Dang, $thing2 is an array but Get-Member is still saying the TypeName is System.String. What’s going on? 
#Well, the key here is what we’re doing is writing the output of $thing2 into Get-Member. So the output of $thing2 is two strings, and that’s what’s actually hitting Get-Member. If we want to see what kind of object $thing2 really is, we need to use a method that’s built into every PowerShell object: GetType(). 

$thing2.GetType()  

#There you go. $thing2 is a System.Array object, just like we thought. 






