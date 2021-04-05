$result = [System.Collections.ArrayList]::new()

$Port = 80
$Timeout = 1000
$remoteHostname = '192.168.1.10'

$tcpClient = New-Object System.Net.Sockets.TcpClient
#$portOpened = $tcpClient.ConnectAsync($remoteHostname, $Port).Wait($Timeout)


                if ($tcpClient.ConnectAsync($remoteHostname, $Port).Wait($Timeout)){
    
                    $string = ($remoteHostname + ' TCP connection to port ' + $Port + ' established')
                    $stringColor = 'Green'
    
                }
                else{
    
                    $string = ($remoteHostname + ' TCP connection to port ' + $Port + ' failed')
                    $stringColor = 'Red'
    
                }
    
                write-host -ForegroundColor $stringColor $string  



$null = $result.Add([PSCustomObject]@{
                RemoteHostname       = $remoteHostname
                RemotePort           = $Port
                PortOpened           = $portOpened
                TimeoutInMillisecond = $Timeout
                })

return $result