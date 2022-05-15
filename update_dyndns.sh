#!/bin/bash
#allow a dyndns name through your firewall. The idea is to set up a crontab
#to look up the dns hostname so you always have access to the server, via
#your port and protocol of choice. I use something like this to keep a VPN
#tunnel open to a server.

#for manual entry, syntax in terminal for UFW....
#./update_dyndns.sh ip port proto, i.e.
#./update_dyndns.sh 192.168.1.1 22 tcp

mkdir -p "$HOME"/logs
#change hostdns entry below.
hostdns=MY_DYNAMIC_DNS.ddns.net
logfile="$HOME"/logs/dyndnsip.log
lastlog="$HOME"/logs/dyndnstime.log
now=$(date)
Current_IP=$(host "$hostdns" | cut -f4 -d' ')

if [ "$1" = "" ]
then
	if [ ! -f "$logfile" ]
	then
#uncomment and choose your port & protocal. I've used sudo in script so log
#data will be stored in the users $HOME directory and not the root directory.
#	sudo ufw allow from $Current_IP to any port XXXX proto udp
#	sudo ufw allow from $Current_IP to any port XXXX proto tcp
	echo "$Current_IP" > "$logfile"
	echo "New host time log created" > "$lastlog"
	else
	Old_IP=$(cat "$logfile" 2> /dev/null)
		if [ "$Current_IP" = "$Old_IP" ]
		then
		echo "IP address has not changed"
		echo "$now : log running every hour, no changes" >> "$lastlog"
		else
#		uncomment and choose your port protocal
# 		sudo ufw allow from $Current_IP to any port XXXX proto udp
#		sudo ufw allow from $Current_IP to any port XXXX proto tcp
		echo "$Current_IP" > "$logfile"
		echo "ufw has been updated"
		echo "$now : New IP updated" >> "$lastlog"
		fi
	fi
else
sudo ufw allow from "$1" to any port "$2" proto "$3"
fi
