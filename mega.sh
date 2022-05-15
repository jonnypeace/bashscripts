#!/bin/bash

# UNDER DEVELOPMENT
# do it all script.
# file browser for editing in vim - tick
# search files and tunnel to nordvpn - tick
# search bookmarks? - tick
# delete files/directories? -to do
# rsync files over ssh using .ssh config file? -to do
# install necessary packages? -in progress

#############################################
# Check packages are installed

if ! sudo dpkg-query -W fzf > /dev/null 2>&1
then
	sudo apt install fzf -y
fi

if ! sudo dpkg-query -W bat > /dev/null 2>&1
then
	sudo apt install bat -y
fi

#############################################
# function for navigating directories, and editing files with vim

function file_dir_vim {
	array=()
	mapfile array < <(sudo find $(pwd) -maxdepth 1)
	array+=("/")
	array+=("..")
	array+=("$HOME")
	fuz=$(for val in "${array[@]}"; do echo $val; done | sort -u | fzf --preview 'batcat --color=always --style=plain {}' |  sed 's/ //')
	while [[ -n "$fuz" ]]
	do
		if [[ -d "$fuz" ]]
		then
			cd "$fuz" || return
			mapfile array < <(sudo find $(pwd) -maxdepth 1)
			array+=("/")
			array+=("..")
			array+=("$HOME")
			fuz=$(for val in "${array[@]}"; do echo $val; done | sort -u | fzf --preview 'batcat --color=always --style=plain {}' | sed 's/ //')
		elif [[ -w "$fuz" && -f "$fuz" ]]
		then
			vim "$fuz"
			unset fuz
		elif [[ -f "$fuz" ]]
		then
			sudo vim "$fuz"
			unset fuz
		fi
	done
}

#############################################
# connect to nordvpn - UNDER DEVELOPMENT

function nord_vpn {
# directory for .ovpn files
dir=/etc/openvpn/ovpn_udp

# list ovpn files in dmenu
vpn=$(sudo find "$dir" -maxdepth 1 -type f -iname "*.ovpn" | awk -F/ '{print $NF}' | sort | fzf --preview 'batcat --color=always --style=plain {}')

# if vpn selected, check .ovpn config, kill existing vpn to avoid conflict, then connect with chosen vpn
if [ "$vpn" ]
then
    if ! grep -i "/etc/openvpn/auth-user.txt" "$dir"/"$vpn"
    then
        sudo sed -i 's|auth-user-pass|auth-user-pass /etc/openvpn/auth-user.txt|' "$dir"/"$vpn"
    fi
    sudo pkill openvpn
    sleep 1
    sudo openvpn "$dir"/"$vpn" 
else
    printf "%s\n" "No vpn selection" && exit 0
fi
}

#############################################
# use your favourite browser to launch a bookmark - UNDER DEVELOPMENT

function browser_book {
browser=/usr/bin/qutebrowser

declare -A shorts

shorts[stv]="https://www.stv.tv"
shorts[twitch]="https://www.twitch.tv"
shorts[youTube]="https://www.youtube.com"
shorts[channel4]="https://www.channel4.com"
shorts[netflix]="https://www.netflix.com/browse"
shorts[gitHub]="https://github.com/jonnypeace"
shorts[linux Foundation]="https://trainingportal.linuxfoundation.org/learn/dashboard"
shorts[amazon]="https://www.amazon.co.uk"
shorts[ebay]="https://www.ebay.co.uk"
shorts[linode]="https://cloud.linode.com/linodes"
shorts[reddit]="https://www.reddit.com"
shorts[udemy]="https://www.udemy.com/home/my-courses/learning/"
shorts[linkedin]="https://www.linkedin.com/jobs/"
shorts[outlookMail]="https://outlook.live.com/mail"
#shorts[]=""

title=$(printf '%s\n' "${!shorts[@]}" | sort | fzf)

if [ "$title" ]; then
    url=$(printf '%s\n' "${shorts[${title}]}" )
    "$browser" "$url"
    else
    echo "No url required" && exit 0
fi
}

#############################################
# while loop for commandline options

while getopts a:ebvh opt
do
	case "$opt" in
		a) echo "we have selected a with $1" ;;
		b) browser_book
		   if [[ -z $title ]]; then break; fi ;;
		e) file_dir_vim
		   if [[ -z $fuz ]]; then break; fi ;;
		v) nord_vpn
		   break ;;
		h) echo "
		Help:
		
		select -a for...
		select -b for browser bookmark launcher
		select -e for file browsing to edit in vim
		select -v for openvpn
		select -h for help
		" ;;
		*) exit
	esac
done
