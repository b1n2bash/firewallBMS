# https://github.com/daxm/fmcapi -- Needs this repository in order to run #
# import fmcapi
import json
import logging
import time
from ipaddress import ip_network, ip_address
import subprocess

# Author: Ben Pirkl
# Date: 02/24/2020
# Purpose: Script that allows manual update of Cisco FMC NetworkGroup object

def main():

	host = "<host>"
	username = "<username>"
	password = "<password>"

	# List of address space(s) that the script should avoid banning
	privNet1 = ip_network("10.0.0.0/8")
	privNet2 = ip_network("172.16.0.0/12")
	privNet3 = ip_network("192.168.0.0/16")
	# pubNet1 = ip_network("<public-address-space>")

	with fmcapi.FMC(host=host,
			username=username,
			password=password,
			autodeploy=False) as fmc1:
	# Define a network group object and register the FMC "Ban_List"
	# object to it.
		netObj = fmcapi.NetworkGroups(fmc=fmc1, name="Ban_List")
	# Pull the contents of Ban_List into netObj
		netObj.get()
	# For each line in the addIPClean.txt file, add the IP to a ban list
	# (Only do this if the IP is not a part of a wanted/known address space)
		ipListAdd = [line.rstrip('\n') for line in open('manualAdd.txt')]
		for ip in ipListAdd:
			addr = ip_address(ip)
			if addr not in (privNet1 or privNet2 or privNet3):
				netObj.unnamed_networks(action="add", value=ip)
		netObj.put()


if __name__ == "__main__":
	main()
