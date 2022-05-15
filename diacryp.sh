#!/bin/bash

#temporary files for redirecting stderr info, plenty of excess in case this grows
temp1=$(mktemp -t test1.XXXXXX)
temp2=$(mktemp -t test2.XXXXXX)
temp3=$(mktemp -t test3.XXXXXX)
temp4=$(mktemp -t test4.XXXXXX)
temp5=$(mktemp -t test5.XXXXXX)
temp6=$(mktemp -t test6.XXXXXX)
temp7=$(mktemp -t test7.XXXXXX)
temp8=$(mktemp -t test8.XXXXXX)
temp9=$(mktemp -t test9.XXXXXX)

# create new encrypted file for mounting
function createnew {

loc=$(pwd)

dialog --title "Create New Crypto" \
--form "\nLocal file/mount can be called without full path ---- ctrl+c to leave" 30 60 10 \
  "Encrpyted File Name" 1 1 "" 1 37 15 50 \
  "byte size, i.e. 1M? (for dd)" 2 1 "" 2 37 15 50 \
  "Count, i.e. 1024 ? (for dd)" 3 1 "" 3 37 15 50 \
  "/dev/mapper/pathname i.e secret" 4 1 "" 4 37 15 50 \
  "Mount Point i.e. /mnt/crypto" 5 1 "" 5 37 15 50 \
2>"$temp2"
if [ $? == 1 ]; then return 1; fi

enfile=$(awk 'NR==1{print}' "$temp2")
bsize=$(awk 'NR==2{print}' "$temp2")
count=$(awk 'NR==3{print}' "$temp2")
secret=$(awk 'NR==4{print}' "$temp2")
mount=$(awk 'NR==5{print}' "$temp2")

mkdir -p "$mount"
clear
echo "File creation in progress........."
dd if=/dev/zero of="$enfile" bs="$bsize" count="$count"
cryptsetup luksFormat --cipher aes-xts-plain64 -s 512 "$enfile"
echo
echo "Please enter newly created password to mount file....."
echo
cryptsetup --verbose luksOpen "$loc"/"$enfile" "$secret"
mkfs.ext4 /dev/mapper/"$secret"
mount /dev/mapper/"$secret" "$mount"
if [[ $? != 0 ]]; then
  dialog --msgbox "Unable to proceed, check file location, are you sudo" 25 60; else
  dialog --msgbox "File mounted in $mount/$enfile" 25 60
fi

}

# mount existing encrypted file as a directory
function existcrypt {

dialog --title "Mount Existing Crypto File" \
  --form "\nLocal file/mount can be called without full path ---- ctrl+c to leave" 30 60 10 \
  "File name or full path" 1 1 "" 1 37 15 50 \
  "/dev/mapper/pathname i.e. secret" 2 1 "" 2 37 15 50 \
  "Location for mount point" 3 1 "" 3 37 15 50 \
2>"$temp2"
if [ $? == 1 ]; then return 1; fi

enfile=$(awk 'NR==1{print}' "$temp2")
secret=$(awk 'NR==2{print}' "$temp2")
mount=$(awk 'NR==3{print}' "$temp2")

mkdir -p "$mount"

clear
cryptsetup --verbose luksOpen "$enfile" "$secret"
mount /dev/mapper/"$secret" "$mount"
if [[ $? != 0 ]]; then
  dialog --msgbox "Unable to proceed, check file location, are you sudo" 25 60; else
  dialog --msgbox "File mounted in $mount/$enfile" 25 60
fi

}

# unmount existing file/directory
function unmount {

dialog --title "Unmount Existing Crypto File" \
  --form "\nLocal mount point can be called without full path ---- ctrl+c to leave" 30 60 10 \
  "/dev/mapper/pathname i.e. secret" 1 1 "" 1 37 15 50 \
  "Location for mount point" 2 1 "" 2 37 15 50 \
2>"$temp2"
if [ $? == 1 ]; then return 1; fi

secret=$(awk 'NR==1{print}' "$temp2")
mount=$(awk 'NR==2{print}' "$temp2")

clear
umount "$mount"
cryptsetup --verbose luksClose "$secret"

if [[ $? != 0 ]]; then
  dialog --msgbox "Unable to proceed, check file location, are you sudo" 25 60; else
  dialog --msgbox "File has been unmounted" 25 60
fi

}

# while loop for main dialog window
while true
  do
  dialog --no-shadow --menu "Crypto Files" 30 60 10 1 "Create New?" 2 "Mount Existing Crypto File?" 3 "Unmount?" 0 "Exit" 2>"$temp1"
  #if [[ $? != 0 ]]
  #then
  #  break
  #fi

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
rm -f "$temp3" 2> /dev/null
rm -f "$temp4" 2> /dev/null
rm -f "$temp5" 2> /dev/null
rm -f "$temp6" 2> /dev/null
rm -f "$temp7" 2> /dev/null
rm -f "$temp8" 2> /dev/null
rm -f "$temp9" 2> /dev/null

#You need to make an appropriate entry in /etc/fstab. There is nothing special about this and it does not refer to encryption in any way. This can be as simple as:

#/dev/mapper/SECRET /mnt ext4 defaults 0 0

# add an entry to /etc/crypttab. This can be as simple as: SECRET /dev/sdc12

#SECRET ​/dev/sdc12
