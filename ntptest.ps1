
param (
    [Parameter(Mandatory=$false)] 
    [switch] $ntp,
    [Parameter(Mandatory=$false)] 
    [switch] $report

);



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




if ($ntp){

    $ntpstate = w32tm /query /peers | select-string "state:"
    $ntppeer = w32tm /query /peers | select-string "peer: (.*),.*" | foreach {$_.matches.groups[1].value}

    if ($ntpstate -like '*Active'){

        $string = ('NTP Server ' + $ntppeer + ' active')
        $stringcolor = 'Green'

    }
    else{

        $string = ('NTP Server ' + $ntppeer + ' not conencted')
        $stringcolor = 'Red'

    }

    write-host -ForegroundColor $stringcolor $string
    if ($report){
        write-output $string | Out-File -Append $exportpath
    }

}
else{
}