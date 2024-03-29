#!/bin/bash

# todo list

# 1. Provide user permissions for mounting without sudo
# 2. Tightly integrate with cryptsetup luks for keeping files safe in case of
#    system failure

#temporary files for redirecting stderr info, plenty of excess in case this grows
temp1=$(mktemp -t test1.XXXXXX)
temp2=$(mktemp -t test2.XXXXXX)

# trap to stop your encryption keys being exposed, and tidy temporary files
function for-trap {

for files in "$PWD"/cryptconfig/*
do
	enfile=$(awk 'NR==1{print}' "$files")
	mount=$(awk 'NR==4{print}' "$files")
	sudo umount "$mount" && rm "$enfile" 2> /dev/null
	rm "$temp1" "$temp2" 2> dev/null
done
clear
exit
}

trap 'for-trap' 2

#function yes-no-contin {
#	ans=$(printf '%s\n' "yes" "no" | fzf --header="Please Select if you want to continue" --margin=10%)
#	return 
#}

# create new encrypted file for mounting
function createnew {

# Create directory within script location directory	
config="$PWD/cryptconfig"
mkdir -p "$config"

# Gather info for the encrypted file and mount point
dialog --no-shadow --title "Create New Crypto" \
--form "\n\nCtrl+c will unmount and delete decrypted file" 30 60 10 \
  "Encrpyted File Name" 1 1 "" 1 37 15 50 \
  "byte size, i.e. 1M? (for dd)" 2 1 "" 2 37 15 50 \
  "Count, i.e. 1024 ? (for dd)" 3 1 "" 3 37 15 50 \
  "Full Mount Point i.e. /mnt/crypto" 4 1 "" 4 37 15 50 \
2>"$temp2"

if [ $? != 0 ]
then
	return
fi

enfile=$(awk 'NR==1{print}' "$temp2")
bsize=$(awk 'NR==2{print}' "$temp2")
count=$(awk 'NR==3{print}' "$temp2")
mount=$(awk 'NR==4{print}' "$temp2")

cp "$temp2" "$config/$enfile"
echo "$(( ${bsize%?} * count )) MB file size" >> "$config/$enfile"

sudo mkdir -p "$mount"
clear
echo "File creation in progress........."
dd if=/dev/zero of="$enfile" bs="$bsize" count="$count"
echo

# Making filesystem for file. This will mount in your location using loopback device later on.
mkfs.ext4 "$enfile"
wait

# Encrypt your file and remove unencrypted file until you're ready to use it.
if gpg -o "$enfile".gpg --symmetric --cipher-algo AES256 "$enfile"
then
	wait
	rm "$enfile"
fi

if [[ $? != 0 ]]; then
  dialog --no-shadow --msgbox "Unable to proceed with encryption" 25 60; else
  dialog --no-shadow --msgbox "\nFile $enfile now encrypted\n\nTo mount file choose option 2 from main menu, for 'mount existing crypto file'\n\nFile located in $config" 25 60
fi

}

# mount existing encrypted file as a directory
function existcrypt {

# Confirm selection of encrypted file to mount
config="$PWD/cryptconfig"
list=$(find "$config" -type f | fzf --header="
Select/Search(type) and press ENTER: " --margin=20% --preview-window=up:25% --preview "cat {}")

if [[ ! $list ]] ; then return ; fi

enfile=$(awk 'NR==1{print}' "$list")
mount=$(awk 'NR==4{print}' "$list")

sudo mkdir -p "$mount"
clear

# Decrypt file and mount at location confirmed by selection above
gpg -o "$enfile" -d "$enfile".gpg
wait
sudo mount "$enfile" "$mount"

if [[ $? != 0 ]]; then
  dialog --no-shadow --msgbox "Unable to proceed, check file location and script path\n\nScript will run best in a dedicated crypto directory in your $HOME" 25 60; else
  dialog --no-shadow --msgbox "File mounted in $mount" 25 60
fi
clear

}

# unmount existing file/directory
function unmount {

# Confirm selection of encrypted file unmount and save back into encrypted file
config="$PWD/cryptconfig"
list=$(find "$config" -type f | fzf --header="
Select/Search(type) and press ENTER: " --margin=20% --preview-window=up:25% --preview "cat {}")
if [[ ! $list ]] ; then return ; fi
enfile=$(awk 'NR==1{print}' "$list")
mount=$(awk 'NR==4{print}' "$list")

clear

# Unmount, and encrypt
if sudo umount "$mount"
then
	wait
	if gpg -o "$enfile".gpg --symmetric --batch --yes --cipher-algo AES256 "$enfile"
	then
		wait
		rm "$enfile"
	fi
fi

if [[ $? != 0 ]]; then
  dialog --no-shadow --msgbox "Unable to proceed, check files and locations?" 25 60; else
  dialog --no-shadow --msgbox "File has been unmounted and encrypted" 25 60
fi

}

# while loop for main dialog window
while true
  do
	  dialog --no-shadow --menu "Crypto Files\nCtrl+c will unmount and delete decrypted file" 30 60 10 1 "Create New encryption file?" 2 "Mount Existing Crypto File?" 3 "Save & Unmount?" 0 "Exit Completely (mounts will still be mounted)" 2>"$temp1"
  if [[ $? != 0 ]]
  then
    break
  fi

  selection=$(cat "$temp1")
  case "$selection" in
  1)
    createnew ;;
  2)
    existcrypt ;;
  3)
    unmount ;;
  0)
    break ;;
  *)
    dialog --no-shadow --msgbox "sorry, invalid selection" 10 30
  esac
done
clear

rm -f "$temp1" 2> /dev/null
rm -f "$temp2" 2> /dev/null
