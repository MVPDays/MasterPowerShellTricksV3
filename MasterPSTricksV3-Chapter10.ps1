$splitstring = 'this is an interesting string with the letters s and t all over the place' 

$splitstring.split('s') 

<#>  
thi 
 i 
 an intere 
ting 
tring with the letter 
  
 and t all over the place  
</#>


$splitstring.split('st') 
  
<#>  
hi 
 i 
 an in 
ere 
  
ing 
  
ring wi 
h 
he le 
  
er 
  
 and 
 all over 
he place  
</#>


$splitstring -split 'st' 
<#>  
this is an intere 
ing  
ring with the letters s and t all over the place  
</#>