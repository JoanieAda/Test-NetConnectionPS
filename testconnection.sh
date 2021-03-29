#!/bin/bash
: << 'commentBlock'
testconnnection.sh [-path <csv file>] [-ntp] [-report]

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
commentBlock


while [ -n "$1" ]; do 
	case "$1" in

	-path)
		serverList="$2"
		shift
		;;

	-ntp) 
		ntp=' ' 
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
#List of ntpservers to poll when the -ntp switch is set
ntpServers=('132.246.11.238' '132.246.11.227' '192.168.1.10')
#List of color codes for prompt
red='\033[0;31m'
green='\033[0;32m'
noColor='\033[0m'


#Generates report path and inserts a leading date line
if [[ $report ]]; then
	exportPath='Report_connection-test_'`date +"%Y-%m-%d"`'.log'
	echo '------------'`date`'------------' >> $exportPath
fi	


#Check the reachability/TCP connection for the hosts in the CSV
if [[ $serverList ]]; then
	for i in `tail -n +2 $serverList`; do
		ip=`printf $i | cut -f 1 -d ';'`
		port=`printf $i | cut -f 2 -d ';'`
		doPing=`printf $i | cut -f 3 -d ';'`
	
		if [ $doPing == 'yes' ]; then
			ping -c 1 $ip &> /dev/null
			if [ $? == 0 ]; then
				string=$ip' ping successful'
				color=$green
			else
				string=$ip' ping failed'
				color=$red
			fi
			echo -e ${color}$string${noColor}
			if [[ $report ]]; then
				echo $string >> $exportPath
			fi			
		fi
	
		if [ $port -gt 0 ]; then
			nc -z $ip $port
			if [ $? == 0 ]; then
				string=$ip' TCP connection to port '$port' established'
				color=$green
			else
				string=$ip' TCP connection to port '$port' failed'
				color=$red
			fi
			echo -e ${color}$string${noColor}
			if [[ $report ]]; then
				echo $string >> $exportPath
			fi	
		fi
	done
fi


#Check NTP reachability to list of NTP servers
if [[ $ntp ]]; then
	for i in ${ntpServers[@]}; do
#		if [[ $(printf "c%47s" | nc -uw1 $i 123 | tr -d '\0') ]]; then							#NTP client query using Version 4
		if [[ $(printf "\x$(printf %x 27)%47s" | nc -uw1 $i 123 | tr -d '\0') ]]; then			#NTP client query using Version 3	
			string='NTP Server '$i' active'
			color=$green
		else
			string='NTP Server '$i' failed'
			color=$red
		fi
		echo -e ${color}$string${noColor}
		if [[ $report ]]; then
			echo $string >> $exportPath
		fi	
	done
fi


#Add new line at the end of the report
if [[ $report ]]; then
	printf '\n' >> $exportPath
fi	
