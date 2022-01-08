
#! /bin/bash

#Typical script i use to update nextcloud to the latest release using docker.
#Could obviously be run in cron, and adapted to many docker images, and more images could be included in this script sequentially.
#I don't mind docker-compose and watchdog, but i found watchdog didn't work all the time, and just prefer this
#overall. If i was using Kubernetes, or docker on a grander scale, I might want to explore other options.
#Be wary of your firewall rules with docker. Docker adopts it's own firewall rules in iptables
#I would google docker iptables. Even more so if you are using a cloud server such as Linode.
#For my linode, I was able to get docker nextcloud to obey my firewall rules with this command.....
#sudo iptables -I DOCKER-USER -i eth0 ! -s my.ip.add.ress -j DROP
#eth0 might be different, so check your interfaces, ip link show, or ip a.
#The ! -s iptables command inverts the rule and allows only that single IP through, so if you have a method such as my update_dyndns.sh script
#in this repo, then you could automate this in your firewall rules, but you will also need to make the rules persistent (google).
#Over time if you use automation for the firewall rule, you might want to clean up your iptables, as only the top entry for DOCKER-USER will be obeyed.
#You can add a range of IP addresses or subnet, but my use is in the cloud, for single IP use. 
#You could probably get this to work through a wireguard range of local IP's as a work around and accessed via wireguard on the nextcloud server. 
#I have a few set ups, and only need the one IP. I found it difficult to get docker to obey my wireguard firewall rules, hence you'll see a
#wireguard script somewhere in here for bare metal wireguard, which helps a lot when adding new users.
#Be wary, i believe some docker images don't persist your data.

shafile='/home/user/ncsha.txt'

oldsha=`cat $shafile`
newsha=$(docker pull ghcr.io/linuxserver/nextcloud | grep sha256 | awk '{print $2}' | awk -F ':' '{print $2}')

if [[ $oldsha == $newsha ]]
then
	echo 'Image used is  already latest version'
else
	echo $newsha > $shafile

        answer=$(docker ps -a | grep nextcloud | awk '{print $1}')

        docker stop $answer

        docker container rm $answer

        docker pull ghcr.io/linuxserver/nextcloud

        docker run -d \
         --name=nextcloud \
         -e PUID=1000 \
         -e PGID=1000 \
         -e TZ=Europe/London \
         -p 443:443 \
         -v /home/user/nextcloud:/config \
         -v /home/user/nextcloud:/data \
         --restart unless-stopped \
         ghcr.io/linuxserver/nextcloud

        if [[ $? != 0 ]]; then
         echo 'error occured trying to run docker'; else
         echo "Docker Container Updated"
        fi
fi
