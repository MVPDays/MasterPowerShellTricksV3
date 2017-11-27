function Get-Square { 
    param ( 
        [int]$Number 
    ) 
    $result = $Number * $Number 
    $result 
}  


#This will just get the square of the number we pass it. Your test might look like this. 

describe 'Get-Square' { 
    it 'squares 1' { 
        Get-Square 1 | Should Be 1 
    } 
  
    it 'squares 2' { 
        Get-Square 2 | Should Be 4 
    } 
  
    it 'squares 3' { 
        Get-Square 3 | Should Be 9 
    } 
}  

#This would work. It would test your function correctly, and give you all the feedback you expect. There’s another way to do this, though. Check out this next example. 

describe 'Get-Square' { 
    $tests = @( 
        @(1,1), 
        @(2,4), 
        @(3,9) 
    ) 
    foreach ($test in $tests) { 
        it "squares #($test[0])" { 
            Get-Square $test[0] | Should Be $test[1] 
        } 
    } 
}  
