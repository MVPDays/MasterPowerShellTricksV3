function Do-Thing { 
    [CmdletBinding()] 
    param ( 
    [Parameter( ParameterSetName = 'Computer','Session' )][string]$Username, 
    [Parameter( ParameterSetName = 'Computer' )][string]$ComputerName, 
    [Parameter( ParameterSetName = 'Session' )][PSSession]$SessionName 
    ) 
# Other code 
}  

#So how do you make a parameter a member of more than one parameter set? You need more [Parameter()] qualifiers. 

function Do-Thing { 
    [CmdletBinding()] 
    param ( 
    [Parameter( ParameterSetName = 'Computer' )] 
    [Parameter( ParameterSetname = 'Session' )] 
    [string]$Username, 
  
    [Parameter( ParameterSetName = 'Computer' )][string]$ComputerName, 
    [Parameter( ParameterSetName = 'Session' )][PSSession]$SessionName 
    ) 
# Other code 
}  


