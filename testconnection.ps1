
param (
    [Parameter(Mandatory=$false)] [switch] $ntp,

    [Parameter(Mandatory=$true)]
    [ValidateScript({ 
        Test-Path $_ -PathType Leaf 
    })]
    [string] $path   
);


<# Static variables for testing
$IP = '192.168.1.10'
$Port = '80'
$Ping = 'yes'
#>


$serverlist=Import-Csv -Path $path -Delimiter ";" -ErrorAction Stop

$serverlist| ForEach-Object {
    try{
        if ($_.Ping -eq 'yes'){         
            if (Test-NetConnection $_.IP -InformationLevel Quiet -ErrorAction Stop -WarningAction SilentlyContinue){

                write-host -ForegroundColor Green $_.IP"ping successful"

        }
            else{

                write-host -ForegroundColor Red $_.IP"ping failed"

            }
        }
        else{            
        }

        if ($_.Port -gt '0'){
            if (Test-NetConnection $_.IP -Port $_.Port -InformationLevel Quiet -ErrorAction Stop -WarningAction SilentlyContinue){

                write-host -ForegroundColor Green $_.IP"TCP connection to port"$_.Port"established"

            }
            else{

                write-host -ForegroundColor Red $_.IP"TCP connection to port"$_.Port"failed"

            }
        }
        else{
        }

    }
    catch{
    }
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