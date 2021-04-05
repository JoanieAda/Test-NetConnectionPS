<# 
testconnnection.ps1 [-path <csv file>] [-ntp] [-report]

This script was built to perform some validation tests based on a csv host list.
-path is followed by the csv file identifying servers/tests to perform 
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
    [Parameter(Mandatory=$false)] [switch] $ntp,
    [Parameter(Mandatory=$false)] [switch] $report,

    [Parameter(Mandatory=$false)]
    [ValidateScript({ 
        Test-Path $_ -PathType Leaf 
    })]
    [string] $path   
);


#Manually set variables
#List of ntpservers to poll when the -ntp switch is set
$ntpServers = @('132.246.11.238','132.246.11.227','192.168.1.11')
#Timeout value for tcpClient
$timeout = 1000


#Generates report path and inserts a leading date line
if ($report){

    $exportPath = Join-Path $PSScriptRoot -ChildPath $('Report_connection-test_'+ (Get-Date).tostring('yyyy-MM-dd') + '.log') 
    write-output ('------------' + (Get-Date) + '------------') | Out-File -Append $exportPath

}
else{
}


#Check the reachability/TCP connection for the hosts in the CSV
if ($path){
    $serverList=Import-Csv -Path $path -Delimiter ";" -ErrorAction Stop
    
    $serverList| ForEach-Object {
        if ($_.Ping -eq 'yes'){         
            if (Test-NetConnection $_.IP -InformationLevel Quiet -ErrorAction Stop -WarningAction SilentlyContinue){
    
                $string = ($_.IP + ' ping successful')
                $stringColor = 'Green'
    
            }
            else{
    
                $string = ($_.IP + ' ping failed')
                $stringColor = 'Red'
    
            }
    
            write-host -ForegroundColor $stringColor $string
            if ($report){
                write-output $string | Out-File -Append $exportPath
            }
    
        }
        else{            
        }
    
        if ($_.Port -gt '0'){
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpConn = $tcpClient.BeginConnect($_.IP, $_.Port, $NULL, $NULL)
            if ($tcpConn.AsyncWaitHandle.WaitOne($timeout, $False)){

                $tcpClient.EndConnect($tcpConn) | Out-Null    
                $string = ($_.IP + ' TCP connection to port ' + $_.Port + ' established')
                $stringColor = 'Green'
    
            }
            else{
    
                $string = ($_.IP + ' TCP connection to port ' + $_.Port + ' failed')
                $stringColor = 'Red'
    
            }

            $tcpClient.Close()

            write-host -ForegroundColor $stringColor $string
            if ($report){
                write-output $string | Out-File -Append $exportPath
            }
    
        }
        else{
        }
    

    }
}
else{
}


#Check NTP #reachability to list of NTP servers
if ($ntp){

    $ntpServers| ForEach-Object {
        try{

            $ntpState = w32tm /stripchart /computer:$_ /samples:1 | select -Index 3  

            if ($ntpState -like '[0-9][0-9]:[0-9][0-9]:[0-9][0-9], d:*'){
               
                $string = ('NTP Server ' + $_ + ' active')
                $stringColor = 'Green'

            }
            else{

                $string = ('NTP Server ' + $_ + ' failed')
                $stringColor = 'Red'

            }

            write-host -ForegroundColor $stringColor $string
            if ($report){
                write-output $string | Out-File -Append $exportPath
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
    write-output `n | Out-File -Append $exportPath
}
