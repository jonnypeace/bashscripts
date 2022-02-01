#!/bin/bash

#Bare Metal wireguard script to add new users.
#my wireguard uses the 10.6.0.0/24 subnet, so you'll have to update this accordingly.
#to save myself some typing time, for the $num variable, i just increment by 1 and this is the last digit of the IP.
#check the wg0.conf file to see which clients are using which IP's.
#also update your endpoint ip address, or dns (i use dynamic dns) for this,line 23
#choose which DNS you'd like to use line 23
#lastly, you'll need the server keys, and the publickey which is added to line 23.
##umask 077; wg genkey | tee privatekey | wg pubkey > publickey

#ubuntu server doesn't allow the edit of the wg0.conf file unless wireguard service has stopped running.
read -p "Warning, this script will halt your wireguard server while adding new users. Proceed? [y/n]? " ans
mkdir -p /etc/wireguard/configs

if [[ $ans =~ ^(yes|y)$ ]]; then

  systemctl stop wg-quick@wg0
  read -p "Enter peer name: " name
  read -p "Enter subnet last digit: " num
  umask 077
  wg genkey | tee $name'_priv' | wg pubkey > $name'_pub'
  umask 077
  wg genpsk > $name'_psk'
  priv=$(cat $name'_priv')
  psk=$(cat $name'_psk')

  touch /etc/wireguard/configs/$name'.conf'

  echo -e "[Interface]\nPrivateKey = $priv\nAddress = 10.6.0.$num/24\nListenPort = 51820\nDNS = 9.9.9.9\n[Peer]\nPublicKey = MYPUBKEY\nPresharedKey = $psk\nEndpoint = MYDNS.ORMY.IP:51820\nAllowedIPs = 0.0.0.0/0, ::0/0" >> /etc/wireguard/configs/$name'.conf'

  pub=$(cat $name'_pub')
  echo -e "###$name###\n[peer]\nPublicKey = $pub\nPresharedKey = $psk\nAllowedIPs = 10.6.0.$num/32\n###end $name###" >> /etc/wireguard/wg0.conf

  systemctl start wg-quick@wg0

  echo "$name has been added to wireguard,config file located /etc/wireguard/configs" ; else
  echo "Exiting Script....."
  exit 0 ;
fi


######Some configurations######
#ufw route allow in on wg0 out on eth0 from 10.6.0.0/24
#nano -l +28 /etc/sysctl.conf and uncomment net.ipv4.ip_forward=1 for debian it's line 28.
#add the below 3 lines to [interface] of wg0.conf. This might be optional, i've not needed this with raspbian, but for a Linode Debian server i have
#needed to add these lines.
######################################
#SaveConfig = true (optional? Seems to store your connection IP in config)
#PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
######################################
