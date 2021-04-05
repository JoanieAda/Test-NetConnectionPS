$result = [System.Collections.ArrayList]::new()

$Port = 30500
$Timeout = 1000
$remoteHostname = '192.168.1.65'

$tcpClient = New-Object System.Net.Sockets.TcpClient
#$portOpened = $tcpClient.ConnectAsync($remoteHostname, $Port).Wait($Timeout)


#                if ($tcpClient.Connect($remoteHostname, $Port).Wait($Timeout)){
#    
#                    $string = ($remoteHostname + ' TCP connection to port ' + $Port + ' established')
#                    $stringColor = 'Green'
#    
#                }
#                else{
#    
#                    $string = ($remoteHostname + ' TCP connection to port ' + $Port + ' failed')
#                    $stringColor = 'Red'
#    
#                }
#    
#                write-host -ForegroundColor $stringColor $string  



#$null = $result.Add([PSCustomObject]@{
#                RemoteHostname       = $remoteHostname
#                RemotePort           = $Port
#                PortOpened           = $portOpened
#                TimeoutInMillisecond = $Timeout
#                })
#
#return $result



 
#$socket=New-Object System.Net.Sockets.TcpClient
#try {
#    $result=$tcpClient.BeginConnect($remoteHostname, $Port, $NULL, $NULL)
#    if (!$result.AsyncWaitHandle.WaitOne($Timeout, $False)) {
#        throw [System.Exception]::new('Connection Timeout')
#    }
#    $tcpClient.EndConnect($result) | Out-Null
#    $tcpClient.Connected
#}
#finally {
#    $tcpClient.Close()
#}

                $tcpConn=$tcpClient.BeginConnect($remoteHostname, $Port, $NULL, $NULL)
                if ($tcpConn.AsyncWaitHandle.WaitOne($Timeout, $False)){
    
                    $string = ($remoteHostname + ' TCP connection to port ' + $Port + ' established')
                    $stringColor = 'Green'
                    
                }
                else{
    
                    $string = ($remoteHostname + ' TCP connection to port ' + $Port + ' failed')
                    $stringColor = 'Red'
    
                }

                write-host -ForegroundColor $stringColor $string  