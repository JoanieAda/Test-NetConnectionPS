<# 
testconnnection.ps1 -path <csv file> [-ntp] [-report]

This script was built to perform some validation tests based on an csv host list.
-path is a mandatory value
-ntp will check the NTP status of the host (may or may not be relevant based on the host config)
-report will save the output file dated of today (output is appended)

CSV file format
IP;Port;Ping
serverip;80;yes

Set Port to '0' to prevent TCP test
Set Ping to 'no' to prevent Ping test

IP can also be an fqdn as long as the host can perform proper name resolution

#>

param (
    [Parameter(Mandatory=$false)] 
    [switch] $ntp,
    [Parameter(Mandatory=$false)] 
    [switch] $report,

    [Parameter(Mandatory=$true)]
    [ValidateScript({ 
        Test-Path $_ -PathType Leaf 
    })]
    [string] $path   
);


#Generates report path and inserts a leading date line
if ($report){

    $originalpath = Get-Item $path
    $exportpath = Join-Path -Path $originalpath.DirectoryName -ChildPath $("Report_"+ $originalpath.BaseName + "_" + (Get-Date).tostring("yyyy-MM-dd") + ".log") 
    write-output ('------------' + (Get-Date) + '------------') | Out-File -Append $exportpath

}
else{
}


#Check the reachability/TCP connection for the hosts in the CSV
$serverlist=Import-Csv -Path $path -Delimiter ";" -ErrorAction Stop

$serverlist| ForEach-Object {
    try{
        if ($_.Ping -eq 'yes'){         
            if (Test-NetConnection $_.IP -InformationLevel Quiet -ErrorAction Stop -WarningAction SilentlyContinue){

                $string = ($_.IP + ' ping successful')
                $stringcolor = 'Green'

            }
            else{

                $string = ($_.IP + ' ping failed')
                $stringcolor = 'Red'

            }

            write-host -ForegroundColor $stringcolor $string
            if ($report){
                write-output $string | Out-File -Append $exportpath
            }

        }
        else{            
        }

        if ($_.Port -gt '0'){
            if (Test-NetConnection $_.IP -Port $_.Port -InformationLevel Quiet -ErrorAction Stop -WarningAction SilentlyContinue){

                $string = ($_.IP + ' TCP connection to port ' + $_.Port + ' established')
                $stringcolor = 'Green'

            }
            else{

                $string = ($_.IP + ' TCP connection to port ' + $_.Port + ' failed')
                $stringcolor = 'Red'

            }

            write-host -ForegroundColor $stringcolor $string
            if ($report){
                write-output $string | Out-File -Append $exportpath
            }

        }
        else{
        }

    }
    catch{
    }
}


#Check NTP #reachability to list of NTP servers
if ($ntp){

    $ntpservers = @('132.246.11.238','132.146.11.227','132.246.11.229')

    $ntpservers| ForEach-Object {
        try{

            $ntpstate = w32tm /stripchart /computer:$_ /samples:1 | select -Index 3  

            if ($ntpstate -like '[0-9][0-9]:[0-9][0-9]:[0-9][0-9], d:*'){
               
                $string = ('NTP Server ' + $_ + ' active')
                $stringcolor = 'Green'

            }
            else{

                $string = ('NTP Server ' + $_ + ' failed')
                $stringcolor = 'Red'

            }

            write-host -ForegroundColor $stringcolor $string
            if ($report){
                write-output $string | Out-File -Append $exportpath
            }

        }
        catch{
        }
    }

}
else{
}


#Add new line at the end of the report
if ($report){
    write-output `n | Out-File -Append $exportpath
}
