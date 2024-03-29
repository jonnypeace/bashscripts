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

os_detail=$(awk -F'"' '/^NAME/{print $2}' /etc/os-release)

if [[ "$os_detail" == "Arch Linux" ]]
then
	os_query="sudo pacman -Q"
	os_install="sudo pacman -S --noconfirm"
	batcat=bat
elif [[ "$os_detail" == "Ubuntu" ]]
then
	os_query="sudo dpkg-query -W"
	os_install="sudo apt install -y"
	batcat=batcat
fi

if ! $os_query fzf > /dev/null 2>&1
then
	$os_install fzf
fi

if ! $os_query  bat > /dev/null 2>&1
then
	$os_install bat
fi

if ! $os_query  mpv > /dev/null 2>&1
then
	$os_install mpv
fi

if ! $os_query  feh > /dev/null 2>&1
then
	$os_install feh
fi

#############################################
# function for yes no prompts to continue

function yes-no-contin {
	ans=$(printf '%s\n' "yes" "no" | fzf --header="Please Select if you want to continue" --margin=10%)
	return 
}

# function for navigating directories, and editing files with vim
function file_dir_vim {
	mapfile -t array < <(sudo find -L "$PWD" -maxdepth 1)
	array+=("/")
	array+=("..")
	array+=("$HOME")
	fuz=$(printf '%s\n' "${array[@]}" | sort -u | fzf --header="CURRENT WORKING DIRECTORY $PWD" --preview "$batcat --color=always --style=plain {}")
	while [[ -n "$fuz" ]]
	do
		if [[ -d "$fuz" ]]
		then
			cd "$fuz" || return 1
			mapfile -t array < <(sudo find -L "$PWD" -maxdepth 1)
			array+=("/")
			array+=("..")
			array+=("$HOME")
			fuz=$(printf '%s\n' "${array[@]}" | sort -u | fzf --header="CURRENT WORKING DIRECTORY $PWD" --preview "$batcat --color=always --style=plain {}")
		elif [[ "$fuz" == *.mp4 || "$fuz" == *.mkv || "$fuz" == *.MKV || "$fuz" == *.MP4 ]]
		then
			mpv "$fuz"
			unset fuz
		elif [[ "$fuz" == *.jpg || "$fuz" == *.JPG || "$fuz" == *.jpeg || "$fuz" == *.JPEG ]]
		then
			feh -F -d -S "$fuz"
			unset fuz
		elif [[ -x "$fuz" ]]
		then
			exec "$fuz" && exit
			unset fuz
		elif [[ -w "$fuz" && -f "$fuz" ]]
		then
			vim "$fuz"
			unset fuz
		elif [[ -f "$fuz" ]]
		then
			sudo vim "$fuz"
			unset fuz
		else
			echo "$fuz not valid"
			unset fuz
		fi
	done
}

#############################################
# connect to nordvpn - UNDER DEVELOPMENT

function nord_vpn {
# directory for .ovpn files
dir=/etc/openvpn/ovpn_udp

# list ovpn files in fzf
vpn=$(sudo find "$dir" -maxdepth 1 -type f -iname "*.ovpn" | awk -F/ '{print $NF}' | sort | fzf --preview "$batcat --color=always --style=plain {}")

# if vpn selected, check .ovpn config, kill existing vpn to avoid conflict, then connect with chosen vpn
if [ "$vpn" ]
then
    if ! grep -i "/etc/openvpn/auth-user.txt" "$dir"/"$vpn"
    then
        sudo sed -i 's|auth-user-pass|auth-user-pass /etc/openvpn/auth-user.txt|' "$dir"/"$vpn"
    fi
    sudo pkill openvpn
    wait
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
		select -e for file browsing, edit in vim, launch applications, picture launcher, movie launcher 
		select -v for openvpn
		select -h for help
		" ;;
		*) exit
	esac
done
