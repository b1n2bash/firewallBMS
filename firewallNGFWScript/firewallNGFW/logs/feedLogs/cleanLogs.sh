#!/bin/sh

# Simple script to clean up the log file
# whenever it gets to be larger than 50,000 lines.
## Script to be called as a cronjob on a consistent basis
SIZEOFLOG=$(cat fmcFeedLogs.log | wc -l)
MAX=50000

# Check if the log-file is longer than MAX lines
# If it is, remove the first X lines of the file
# untill its back to MAX lines.

if [ "$SIZEOFLOG" -gt "$MAX" ]; then
	cutDown=$(( $SIZEOFLOG - $MAX ))
	sed -i -e "1,$(echo $cutDown)d" fmcFeedLogs.log
fi
