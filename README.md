### FirewallBMS
## Firewall Blacklist Management System designed to work with Cisco FMC and Splunk

The firewallBMS program is a script-set written in a mixture of bash and python3 
that allows the user to create/manage a custom Blacklist which bans malicious
IPs for a length of time based on the Splunk reports you feed it. This version of the script
is currently configured for NGFW logs but can easily be tweeked to support more.

For basic test executions, there are no requirements except having at least Python 3.67 installed.

For full program functionality, the following are needed:
-> A Splunk custom script that re-populates the ngfwReport.csv 
   file with new report data
-> A Web-server where the Ban Feed is hosted (and is reachable through the Cisco FMC server)
-> A Cisco FMC Server with a Custom Security Intelligence Blacklist created and attached to the 
   web server.
-> A working Installation of the python fmcapi package (Credit: https://github.com/daxm/fmcapi)

## NOTE: 
If you are testing the full program functionality, please modify the following values to match
your situation. Please further note that these are the *MINIMAL* changes needed in order to attain full
functionality.

**1. firewallNGFW_add2Ban.sh**
```
15. cd <directory>/firewallNGFWScript 
    -> Add the path to the file, this will be important for automating the script in a cronjob.
120. scp $BANFEED <username>@<ip>:<feed-directory>/$BANFEED
    -> After generating ssh keys to allow for the feed to migrate to the webserver, fill in the information. 
```
**2. firewallNGFW_ban-update.py & updateCFMC.py**
```
18. host = '<hostname>' # Location of Cisco FMC #
19. username = '<username>' # User account with permissions to access api 
20. password = '<password>' # User password. Recommended that you store the password elsewhere and then import it here.
```

