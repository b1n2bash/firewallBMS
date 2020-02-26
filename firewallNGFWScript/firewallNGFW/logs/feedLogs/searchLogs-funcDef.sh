#!/usr/bin/env bash

# Author: Ben Pirkl
# Date: 02/24/2020
# Purpose:
# This file contains the function definitions
# used in searchLogs.sh

# Display the Help Menu
helpMenu(){
	echo " "
	echo "Usage:"
	echo " Search by IP:"
	echo "	$0 ip-address(s)"
	echo "		Example: $0 1.2.3.4 2.3.4.5 3.4.5.6 [etc...] "
	echo " Search by Date:"
	echo "	$0 <date> [-i <IP(s)> (optional)]"
	echo "		Example: $0 year-month-day"
	echo "		Example: $0 2020-02-12 -i 1.2.3.4 2.3.4.5 3.4.5.6"
	echo "        $0 -f <date> -t <date> [-i <IP(s)> (optional)]"
	echo "        [-f] [-t] : define a date-range search from -f <date> to -t <date>"
	echo "		Example: $0 -f 2020-02-12 -t 2020-02-14 -i 1.2.3.4.5"
	echo " List Repeating Offenders:"
	echo "        $0 -rO -n <number of lines to return> [-o <Output file> (optional)]"
	echo " 		Example: $0 -rO -n 10"
	echo "		Example: $0 -rO -n 10 -o offenderIP.txt"
	echo " Display This Menu: "
	echo "        $0 -h"
	echo " "
	exit 1
}

# Function that finds IPs that show up more than twice in the logs.
# $1 is the number of lines that the user wants, $2 is the -o flag, $3 is the intended output file name.
repOffenders(){
	REP=$(cat $LOG | grep "IP-Add" | awk 'NF>1{print $NF}' | sort | uniq -d -c | sort -r)
	if [[ $2 == "-o" ]]
	then
		echo "Redirecting output to file..."
		echo "## Repeated Offenders ###" > $3
		echo "    Num IP " > $3
		echo "$REP" | head -"$1" > $3
	else
		echo "#########################"
		echo "## Repeated Offenders ###"
		echo "    Num IP "
		echo "$REP" | head -"$1"
		echo "#########################"
	fi
	exit 1
}

# Function that searches through the log file for
# IPs
ipSearch(){
    IPCHK=$(echo "$1" | egrep -o "$IP")
	if [ -n "$IPCHK" ]
	then
		VALID=$(cat $LOG | grep "IP-Added" | grep -F "$IPCHK")
		if [ -n "$VALID" ]
		then
			echo "#########################"
			echo "$VALID"
			echo " "
			FIRST=$(cat $LOG | grep "IP-Added" | grep "$IPCHK" | head -1)
			echo "Earliest entry found: "
			echo "	$FIRST"
		else
			echo "#########################"
			echo "No Logs found for given IP: $1"
		fi
	fi
}
