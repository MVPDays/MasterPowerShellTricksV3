#In our scenario, I’ve got a filename and I’m going to split it based on the slashes in the path. Normally I’d get something like this.


$filename = get-item C:\temp\demo\thing.txt  
$filename -split '\\'   

 C:  
temp  
demo  
thing.txt   

#Notice how I had to split on “\”? I had to escape that backslash. We’re regexing already! Also notice that I lost the backslash on which I split the string. Now let’s do a tiny bit more regex in our split pattern to retain that backslash.  


$filename -split '(?=\\)'  
  
C:  
\temp  
\demo  
\thing.txt   
#Look at that, we kept our backslash. How? Well look at the pattern we split on: (?=\). That’s what regex calls a “lookahead”. It’s contained in round brackets and the “?=” part basically means “where the next character is a ” and the “\” still means our backslash. So we’re splitting the string on the place in the string where the next character is a backslash. we’re effectively splitting on the space between characters.  
#NEAT! Now what if I wanted the backslash to be on the other side? That is, at the end of the string on each line instead of the start of the line after? No worries, regex has you covered there, too.  

$filename -split '(?<=\\)'  
  
C:\  
temp\  
demo\  
thing.txt   

#This is a “lookbehind”. It’s the same as a lookahead, except it’s looking for a place where the character to the left matches the pattern, instead of the character to the right. A lookbehind is denoted with the “?<=” characters.  
#There are plenty of resources online about using lookaheads and lookbehinds in regex, but if you’re not looking specifically for regex resources, you probably wouldn’t have found them. If PowerShell string splitting is what you’re after, hopefully you found this interesting.  
#Regex isn’t that scary, right?  
