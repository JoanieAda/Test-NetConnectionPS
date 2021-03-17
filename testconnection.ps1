
param (
    [Parameter(Mandatory=$false)] [switch] $ntp
);

$IP = '192.168.1.10'
$Port = '80'
$Ping = 'yes'



if ($Ping -eq 'yes'){         
    if (Test-NetConnection $IP -InformationLevel Quiet -ErrorAction Stop){

        write-host -ForegroundColor Green "$IP ping successful"

    }
    else{

        write-host -ForegroundColor Red "$IP ping failed"

    }
}
else{            
}



if ($Port -gt '0'){
    if (Test-NetConnection $IP -Port $Port -InformationLevel Quiet -ErrorAction Stop){

        write-host -ForegroundColor Green "$IP TCP connection to port $Port established"

    }
    else{

        write-host -ForegroundColor Red "$IP TCP connection to port $Port failed"

    }
}
else{
}



if ($ntp){

    $ntpstate = w32tm /query /peers | select-string "state:"
    $ntppeer = w32tm /query /peers | select-string "peer: (.*),.*" | foreach {$_.matches.groups[1].value}

    if ($ntpstate -like '*Active'){

        write-host -ForegroundColor Green "NTP Server $ntppeer Active"

    }
    else{

        write-host -ForegroundColor Red "NTP Server $ntppeer Failed"

    }
}
else{
}




<#
[CmdletBinding()]
Param(
  
  [Parameter(Mandatory=$True,Position=1)]

    [ValidateScript({
        
        Test-Path $_ -PathType Leaf

    })]

   [string]
   $Path
)


$checkList=Import-Csv -Path $Path -Delimiter ";" -ErrorAction Stop

$checkList| ForEach-Object {

    try{
        
        if (Test-NetConnection -ComputerName $_.Server -Port $_.Port -InformationLevel Quiet -ErrorAction Stop){
            
            $_.Open=$true
        
        }else{
            
            $_.Open=$false
        
        }
    
    }catch{
        #Nothing we can do because the -ErrorAction is ignored 
    }
}


$outputObject=Get-Item $Path

#Build file name for the report
$exportPath= Join-Path -Path $outputObject.DirectoryName -ChildPath $("Report_"+ $outputObject.BaseName + $outputObject.Extension)

$checkList | Export-Csv -Path $exportPath -NoTypeInformation -Delimiter ";" -ErrorAction Stop

#>


<#
CSV file format

Server;Port;Open
servername;80;

#>