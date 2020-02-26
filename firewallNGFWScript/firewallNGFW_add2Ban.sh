#!/usr/bin/env bash

# Author: Ben Pirkl
# Date: 11/25/2019
#
# Program: firewallNGFW_add2Ban.sh
# Functionality:
# Parse NGFW report into a list of IPs then send them to firewallNGFW_ban-update.py

# CD to the location where the script is running (Necessary for Cronjob to run)
	# Add a cronjob to execute this script depending on how frequently you wish for the
	# feed to update.
	
# Execute script from one directory above to test this
# cd <directory>/firewallNGFWScript

########################################
## Report and File Pathing for Crontab #
FILEPATH=firewallNGFW
REPORT=$FILEPATH/ngfwReport.csv
########################################
## INTERMEDIATE FILES ##################
PIPCLEAN=$FILEPATH/parsedIPClean.txt
FIPCLEAN=$FILEPATH/finalIPClean.txt
FIPDATE=$FILEPATH/finalIPDate.txt
AIPCLEAN=$FILEPATH/addIPClean.txt
AIPDATE=$FILEPATH/addIPDate.txt
RIPCLEAN=$FILEPATH/removeIPClean.txt
RIPDATES=$FILEPATH/removeIPDates.txt
## INTERMEDIATE FILES ##################
########################################
## Location of the ban-feed file to ####
## be sent to the web server ###########
BANFEED=$FILEPATH/ngfwBanFeed.txt
# Current date and the date of which the ban should be removed
CURRDATE=$(date '+%F')
RBANDATE=$(date '+%F' -d "-7 days")
# Script to update the Network Group Object on Cisco FMC
BANSCRIPT=$FILEPATH/firewallNGFW_ban-update.py
# Script to update the text feed sitting on webserver
PARSESCRIPT=$FILEPATH/ngfwParseFeed.py
LOGFILE=$FILEPATH/logs/feedLogs/ngfwFeedLogs.log
########################################

# Make sure that the files are sorted before any comparisons are made
sort $FIPCLEAN -o $FIPCLEAN

# Grab all source IPs from the report
cat $REPORT | cut -d ',' -f-2 | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '!seen[$0]++' > $PIPCLEAN
sort $PIPCLEAN -o $PIPCLEAN

# Find all New IPs that are not in the current IP banlist
comm -32 $PIPCLEAN $FIPCLEAN > $AIPCLEAN
sort $AIPCLEAN -o $AIPCLEAN

# Create a duplicate list of IPs to add with the date appended at the end
cat $AIPCLEAN | sed -e "s/$/ $CURRDATE/" > $AIPDATE

# Add the clean IPs to the master clean IP list.
cat $AIPCLEAN >> $FIPCLEAN
# Add these dated IPs to a master dated IP list.
cat $AIPDATE >> $FIPDATE

# Find the IPs that have been banned for a week or more, and add them to a list
# to be unbanned
>$RIPCLEAN
cat $FIPDATE | cut -d ' ' -f2 | awk '!seen[$0]++' > $RIPDATES
for dateLine in $(cat $RIPDATES);
do
	if [[ "$dateLine" < "$RBANDATE" ]] ;
	then
		grep "$dateLine" $FIPDATE | cut -d ' ' -f1 >> $RIPCLEAN
		sed -i "/ $dateLine/d" $FIPDATE
	fi
done
sort $FIPDATE -o $FIPDATE

# Clean up the master IP list as well.
# For all of the IPs in removeIPClean, find and remove them from finalIPClean.txt
# Also, add them to the logfile
if [ -s "$RIPCLEAN" ]
then
	for ipLine in $(cat $RIPCLEAN);
	do
		sed -i "/$ipLine/d" $FIPCLEAN
		checkValid=$(grep "$ipLine" $BANFEED)
		if [ -n "$checkValid" ] ; then
			echo "IP-Removed:" $(date '+%F') $(date '+%T') "-->" $ipLine >> $LOGFILE
		fi
	done
else
	>$RIPCLEAN
fi
# Sort the output files
sort $FIPCLEAN -o $FIPCLEAN

# Do some logging for AIPCLEAN
# For all of the IPs in addIPClean, log them in $LOGFILE
if [ -s "$AIPCLEAN" ]
then
	for ipLine in $(cat $AIPCLEAN);
	do
		checkValid=$(grep "$ipLine" $BANFEED)
		if [ -z "$checkValid" ] ; then
			echo "IP-Added:  " $(date '+%F') $(date '+%T') "-->" $ipLine >> $LOGFILE
		fi
	done
fi

# Run the ngfwBanUpdate script to update the Network Object Group
# ##### CURRENTLY NOT IN USE #####
# python3 $BANSCRIPT

# #### CURRENTLY ACTIVE SCRIPT #####
# Run the parsing script to update the Dynamic FMC Security Intelligence Feed
python3 $PARSESCRIPT

# Update the feed:
#  -> Send the ngfwBanFeed.txt file over to server where Static IP list is hosted
# scp $BANFEED <username>@<ip>:<feed-directory>/$BANFEED

# Cleanup #
rm -f $AIPDATE $RIPDATES $PIPCLEAN $RIPCLEAN $AIPCLEAN
