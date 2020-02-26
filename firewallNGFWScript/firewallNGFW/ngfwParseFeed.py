from ipaddress import ip_network, ip_address

# Author: Ben Pirkl
# Date: 11/20/2019
# Purpose:
# Script to parse out IP-addresses that are known to be
# legitimate from the custom Cisco FMC Blacklist Feed

def main():

	# List of owned address spaces and other networks that the script should avoid banning
	privNet1 = ip_network("10.0.0.0/8")
	privNet2 = ip_network("172.16.0.0/12")
	privNet3 = ip_network("192.168.0.0/16")
	# pubNet1 = ip_network("<public-ip-space>")

	# Write to ngfwBanFeed.txt. Parse out lines containing addresses from sources
	# known to be legitimate
	parseOutIP = open("firewallNGFW/ngfwBanFeed.txt", "w+")
	ipListAdd = [line.rstrip('\n') for line in open('firewallNGFW/finalIPClean.txt')]
	for ip in ipListAdd:
		addr = ip_address(ip)
		if addr not in (privNet1 or privNet2 or privNet3):
			parseOutIP.write(str(addr) + "\n")
	parseOutIP.close()

if __name__ == "__main__":
	main()
