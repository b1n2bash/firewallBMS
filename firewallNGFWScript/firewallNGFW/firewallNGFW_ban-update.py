# https://github.com/daxm/fmcapi -- Needs this repository in order to run #
# import fmcapi
import json
import logging
import time
from ipaddress import ip_network, ip_address
import subprocess

# Author: Ben Pirkl
# Date: 02/24/2020
# Purpose:
# This script utilizes the Cisco FMC Static NetworkGroup object
# function to reflexively ban malicious IPs


def main():

	host = "<hostname>"
	username = "<username>"
	password = "<password>"

	# List of owned address space and others that the script should avoid banning
	privNet1 = ip_network("10.0.0.0/8")
	privNet2 = ip_network("172.16.0.0/12")
	privNet3 = ip_network("192.168.0.0/16")
	# pubNet1 = ip_network("<public-ip>")

	with fmcapi.FMC(host=host,
			username=username,
			password=password,
			file_logging="firewallNGFW/logs/netObjLogs/feedNGFW_ban-update.log",
			autodeploy=False) as fmc1:
	# Define a network group object and register the FMC "Feed_List"
	# object to it.
		netObj = fmcapi.NetworkGroups(fmc=fmc1, name="Feed_List")
	# Pull the contents of Feed_List into netObj
		netObj.get()
	# For each line in the addIPClean.txt file, add the IP to a ban list
	# (Only do this if the IP is not a part of the accepted address spaces)
		ipListAdd = [line.rstrip('\n') for line in open('firewallNGFW/addIPClean.txt')]
		for ip in ipListAdd:
			addr = ip_address(ip)
			if addr not in (privNet1 or privNet2 or privNet3):
				netObj.unnamed_networks(action="add", value=ip)
	# Remove the IPs who have been banned for a week from the Network Object.
		ipListRemove = [line.rstrip('\n') for line in open('firewallNGFW/removeIPClean.txt')]
		for ip in ipListRemove:
			netObj.unnamed_networks(action="remove", value=ip)
	# Push the changes onto FMC
		netObj.put()

if __name__ == "__main__":
	main()
