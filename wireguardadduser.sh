#!/bin/bash

#Bare Metal wireguard script to add new users.
#my wireguard uses the 10.6.0.0/24 subnet, so you'll have to update this accordingly.
#to save myself some typing time, for the $num variable, i just increment by 1 and this is the last digit of the IP.
#check the wg0.conf file to see which clients are using which IP's.
#also update your endpoint ip address, or dns (i use dynamic dns) for this.
#choose which DNS you'd like to use also.
#lastly, your public key will be your server_pub key.

read -p "Enter peer name: " name
read -p "Enter subnet last digit: " num
umask 077
wg genkey | tee $name'_priv' | wg pubkey > $name'_pub'
umask 077
wg genpsk > $name'_psk'
priv=$(cat $name'_priv')
psk=$(cat $name'_psk')

touch /etc/wireguard/configs/$name'.conf'

echo -e "[Interface]\nPrivateKey = $priv\nAddress = 10.6.0.$num/24\nListenPort = 51820\nDNS = 9.9.9.9\n[Peer]\nPublicKey = XXXXXXXXXXXXXXXXXXXX\nPresharedKey = $psk\nEndpoint = MYDNS.ddns.net:51820\nAllowedIPs = 0.0.0.0/0, ::0/0" >> /etc/wireguard/configs/$name'.conf'

pub=$(cat $name'_pub')
echo -e "###$name###\n[peer]\nPublicKey = $pub\nPresharedKey = $psk\nAllowedIPs = 10.6.0.$num/32\n###end $name###" >> /etc/wireguard/wg0.conf

systemctl restart wg-quick@wg0

echo "$name has been added to wireguard,config file located /etc/wireguard/configs"
