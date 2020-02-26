#!/usr/bin/env bash

# Author: Ben Pirkl
# Date: 2020-02-21
#
# Purpose:
# This script provides simple log parsing
# capabilities that allow the user to
# easily filter through the feedLogs.log
# file found in this directory.

CURRDATE=$(date '+%F')
LOG=feedLogs.log
NUM='^[0-9]+$'
DEFAULTN=50
DATE="202[0-9]-[0-1][0-9]-[0-9][0-9]"
IP='([0-9]{1,3}\.){3}[0-9]{1,3}'
# Simple script to automate searching the log file

# Load the function definitions into the script
source ./searchLogs-funcDef.sh

if [[ "$#" -lt "1" ]] || [[ $1 == "-h" ]]
then
	# Call the Help Menu Function
	helpMenu

elif [[ $1 == "-rO" ]] && [[ $2 == "-n" ]]
then
	# Call the Repeate Offenders Function
	# $3 is number of lines user wants to print, $4 is the -o flag, $5 is the output file name
	if [[ $3 =~ $NUM ]]
	then
		repOffenders $3 $4 $5
	# If the user doesnt enter a number after -n, default to a value of 50
	elif [[ $3 == "-o" ]] || [ -s "$3" ]
	then
		repOffenders $DEFAULTN $3 $4
	fi
elif [[ $1 == "-f" ]] && [[ $3 == "-t" ]]
then
	# Test
	if [[ $2 =~ $DATE ]] && [[ $4 =~ $DATE ]]
	then
		if [[ $5 == "-i" ]]
		then
			# Save Date Output before Shifting 2
			FROM_DATE=$2
			TO_DATE=$(date +%y-%m-%d -d "$4 + 1 day")
			# Shift all parameters down by two.
			shift 5
			# The rest of the arguments should be IPs.
			# Grep through the log file to find them and
			# print the lines that match both IP and the
			# date (if any)
			for arg in "$@"
			do
				# Check that the argument is a valid ip
    				IPCHK=$(echo "$arg" | egrep -o "$IP")
				# If it is, IPCHK should containt something
   			if [ -n "$IPCHK" ]
				then
					# Search in a range of dates, retrieving lines that fall between them.
			    		VALID=$(cat $LOG | sed -rne "/$FROM_DATE/,/$TO_DATE/ p" | sed '$d' | grep -F "$IPCHK")
			    if [ -n "$VALID" ]
					then
						echo "#########################"
						echo "$VALID"
						echo " "
						FIRST=$(echo "$VALID" | head -1)
						if [ -n "$FIRST" ]
						then
							echo "Earliest entry found: "
							echo "$FIRST"
						fi
					else
						echo "#########################"
						echo "No Logs found for given IP: $1"
					fi
				fi
			done
		fi
	fi
# Search with a singular date
elif [[ $1 =~ $DATE ]]
then
	if [[ "$2" == "-i" ]]
	then
		# Save Date Output before Shifting 2
		FDATE=$1
		# Shift all parameters down by two.
		shift 2
		# The rest of the arguments should be IPs.
		# Grep through the log file to find them and
		# print the lines that match both IP and the
		# date (if any)
		for arg in "$@"
		do
			# Check that the argument is a valid ip
    			IPCHK=$(echo "$arg" | egrep -o "$IP")
			# If it is, IPCHK should containt something
   			if [ -n "$IPCHK" ]
			then
			    # Check if the IP can be found in the log file.
			    VALID=$(cat $LOG | grep "$FDATE" | grep -F "$IPCHK")
			    	if [ -n "$VALID" ]
				then
					echo "#########################"
					echo "$VALID"
					echo " "
					FIRST=$(cat $LOG | grep "$IPCHK" | grep "$FDATE" | head -1)
					if [ -n "$FIRST" ]
					then
						echo "Earliest entry found: "
						echo "$FIRST"
					fi
				else
					echo "#########################"
					echo "No Logs found for given IP: $1"
				fi

			fi
		done
	else
		cat $LOG | grep "$1"
	fi

# If the arguments are all IPs
else
	for arg in "$@"
	do
	    ipSearch $arg
	done
	echo "#########################"

fi

exit 1
