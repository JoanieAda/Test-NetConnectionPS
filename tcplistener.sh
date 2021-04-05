#!/bin/bash
: << 'commentBlock'
tcplistener.sh [-port <port num>] [-report] [-timeout <idle timeout in minutes>]

This script was built to perform some validation tests based on an csv host list.
-port port number to listen on, if ommited default value of 5000 will be used
-report will save the output file dated of today (output is appended)
-timeout will set the idle timeout value to X minutes (default: 5 minutes)

Script will listen on the specified TCP port and will indicate if connections are established.
commentBlock


while [ -n "$1" ]; do 
    case "$1" in

    -port)
        port="$2"
        shift
        ;;

    -timeout) 
        timeout="$2"
        shift
        ;;

    -report) 
        report=' ' 
        ;;

    *) 
        echo "Option $1 not recognized" 
        ;;

    esac

    shift

done


#Manually set variables
#List of color codes for prompt
red='\033[0;31m'
green='\033[0;32m'
cyan='\033[0;36m'
yellow='\033[1;33m'
noColor='\033[0m'


#Check for timeout argument or set to default value
if [[ $timeout ]]; then
    idleTimeout=$((timeout*60))
else
    idleTimeout=300
fi  


#Check is port is defined otherwise used default 5000
if [[ -z $port ]]; then
    port=5000
fi  


#Generates report path and inserts a leading date line
if [[ $report ]]; then
    exportPath='Report_tcplistener_'$port'_'`date +"%Y-%m-%d"`'.log'
    echo '------------'`date`'------------' >> $exportPath
fi  



##Mesage to indicate server is starting to listen
string='Server listening on TCP port '$port
echo -e ${green}$string${noColor}
if [[ $report ]]; then
    echo $string >> $exportPath
fi

##Listen to oncoming conenctions, prompt user if script should continue listening
while [ True ]; do
    netConn=$(timeout $idleTimeout's' nc -lvn4 -p $port 2>&1)
    if [ $? == 0 ]; then
        remoteIp=$(echo $netConn | awk -F ' ' '{ print $(NF-1) }')
        remotePort=$(echo $netConn | awk -F ' ' '{ print $(NF) }')
        string='Connection from '$remoteIp' established'
        color=$cyan

        echo -e ${color}$string${noColor}
        if [[ $report ]]; then
            echo $string >> $exportPath
        fi
    else
        break      
    fi

    printf "${yellow}Wait for additional connections? (y/n): ${nocolor}"
    read answer
    while [[ $answer != 'y' && $answer != 'Y' && $answer != 'n' && $answer != 'N' ]]; do
        printf "${yellow}Answer must be y/Y or n/N: ${nocolor}"
        read answer
    done

    if [[ $answer == 'n' || $answer == 'N' ]]; then
        break
    fi

done  

##Mesage to indicate server is no longer listening and final report line
string='Server closed TCP port '$port
echo -e ${red}$string${noColor}
if [[ $report ]]; then
    echo $string >> $exportPath
fi

