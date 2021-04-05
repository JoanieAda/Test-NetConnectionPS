<# 
tcplistener.ps1 -port <port num> [-report] [-timeout <idle timeout in minutes>]

This script was built to perform some validation tests based on an csv host list.
-port is a mandatory value
-report will save the output file dated of today (output is appended)
-timeout will set the idle timeout value to X minutes (default: 5 minutes)

Script will listen on the specified TCP port and will indicate if connections are established.

#>

param (
    [Parameter(Mandatory=$true)] [int] $port,
    [Parameter(Mandatory=$false)] [switch] $report,
    [Parameter(Mandatory=$false)] [int] $timeout
);


#Check for timeout argument or set to default value
if ($timeout) {

    $idleTimeout = New-TimeSpan -Minutes $timeout

}
else{

    $idleTimeout = New-TimeSpan -Minutes 5

}


#Generates report path and inserts a leading date line
if ($report){

    $exportPath = Join-Path $PSScriptRoot -ChildPath $('Report_tcplistener_' + $port + '_' + (Get-Date).tostring('yyyy-MM-dd') + ".log") 
    write-output ('------------' + (Get-Date) + '------------') | Out-File -Append $exportPath

}


#Start stopWatch for the idleTimeout
$stopWatch = [System.Diagnostics.Stopwatch]::StartNew()


#Set  TCP listener and starts it
$listener = [System.Net.Sockets.TcpListener]$port
$listener.Start()

$string = ('Server listening on TCP port ' + $port)
write-host -ForegroundColor Green $string
if ($report){
    write-output $string | Out-File -Append $exportPath
}


#Listen to oncoming conenctions, prompt user if script should continue listening
while($stopWatch.elapsed -lt $idleTimeout){

    if ($listener.Pending()) { 

        $client = $listener.AcceptTcpClient()

        $string = ('Connection from ' + $client.Client.RemoteEndPoint.Address + ' established')
        write-host -ForegroundColor Cyan $string
        if ($report){
            write-output $string | Out-File -Append $exportPath
        }

        write-host -ForegroundColor Yellow -NoNewLine 'Wait for additional connections? (y/n): '
        $answer = read-host

        while (!$answer -OR ($answer -ne 'y' -AND $answer -ne 'Y' -AND $answer -ne 'n' -AND $answer -ne 'N')){

            write-host -ForegroundColor Yellow -NoNewLine 'Answer must be y/Y or n/N: '
            $answer = read-host

        }

        if ($answer -eq "n" -or $answer -eq "N"){

            break

        }
        else{

            $stopWatch.Restart()

        }
        $client.Close()

    }
}


#Stop the listener and write final report lines
$listener.Stop()
$string = ('Server closed TCP port ' + $port)
write-host -ForegroundColor Red $string
if ($report){
    write-output $string | Out-File -Append $exportPath
    write-output `n | Out-File -Append $exportPath
}

