#!/bin/bash

# defaults
file_name='cryptofile'
byte_size='1M'
count_byte='1024'
mapper='cryptofile'
mount_point='/mnt/cryptofile'

# create new encrypted file for mounting
function createnew {
  loc="$PWD"
  local -a new_input
  mapfile -t new_input <<< "$(dialog --no-shadow --title "Create New Crypto" \
    --form "\nLocal file/mount can be called without full path ---- ctrl+c to leave" 30 0 10 \
    "Encrpyted File Name" 1 1 "$file_name" 1 37 30 0 \
    "byte size, i.e. 1M? (for dd)" 2 1 "$byte_size" 2 37 30 0 \
    "Count, i.e. 1024 ? (for dd)" 3 1 "$count_byte" 3 37 30 0 \
    "/dev/mapper/pathname i.e secret" 4 1 "$mapper" 4 37 30 0 \
    "Mount Point i.e. /mnt/crypto" 5 1 "$mount_point" 5 37 30 0 3>&1 1>&2 2>&3 3>&- )"
  if [[ $? == 1 ]]; then return 1; fi

  enfile="${new_input[0]}"
  bsize="${new_input[1]}"
  count="${new_input[2]}"
  secret="${new_input[3]}"
  mount="${new_input[4]}"

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
    dialog --no-shadow --msgbox "Unable to proceed, check file location, are you sudo" 25 60; else
    dialog --no-shadow --msgbox "File mounted in $mount/$enfile" 25 60
  fi
}

# mount existing encrypted file as a directory
function existcrypt {

  local -a old_crypt
  mapfile -t old_crypt <<< "$(dialog --no-shadow --title "Mount Existing Crypto File" \
    --form "\nLocal file/mount can be called without full path ---- ctrl+c to leave" 30 0 10 \
    "File name or full path" 1 1 "$file_name" 1 37 30 0 \
    "/dev/mapper/pathname i.e. secret" 2 1 "$mapper" 2 37 30 0 \
    "Location for mount point" 3 1 "$mount_point" 3 37 30 0 3>&1 1>&2 2>&3 3>&-)"
  if [[ $? == 1 ]]; then return 1; fi

  enfile="${old_crypt[0]}"
  secret="${old_crypt[1]}"
  mount="${old_crypt[2]}"

  mkdir -p "$mount"

  clear
  cryptsetup --verbose luksOpen "$enfile" "$secret"
  mount /dev/mapper/"$secret" "$mount"
  if [[ $? != 0 ]]; then
    dialog --no-shadow --msgbox "Unable to proceed, check file location, are you sudo" 25 60; else
    dialog --no-shadow --msgbox "File mounted in $mount/$enfile" 25 60
  fi
}

# unmount existing file/directory
function unmount {

  local -a un_mount
  mapfile -t un_mount <<< "$(dialog --no-shadow --title "Unmount Existing Crypto File" \
    --form "\nLocal mount point can be called without full path ---- ctrl+c to leave" 30 0 10 \
    "/dev/mapper/pathname i.e. secret" 1 1 "$mapper" 1 37 30 0 \
    "Location for mount point" 2 1 "$mount_point" 2 37 30 0 3>&1 1>&2 2>&3 3>&-)"
  if [[ $? == 1 ]]; then return 1; fi

  secret="${un_mount[0]}"
  mount="${un_mount[1]}"

  clear
  umount "$mount"
  cryptsetup --verbose luksClose "$secret"

  if [[ $? != 0 ]]; then
    dialog --no-shadow --msgbox "Unable to proceed, check file location, are you sudo" 25 60; else
    dialog --no-shadow --msgbox "File has been unmounted" 25 60
  fi
}


# while loop for main dialog window
while true
do
  selection=$(dialog --no-shadow --menu \
    "Crypto Files" 30 60 10 \
    1 "Create New?" \
    2 "Mount Existing Crypto File?" \
    3 "Unmount?" \
    0 "Exit" 3>&1 1>&2 2>&3 3>&-)

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

# FOR AUTOMOUNTING...
#You need to make an appropriate entry in /etc/fstab. There is nothing special about this and it does not refer to encryption in any way. This can be as simple as:

#/dev/mapper/SECRET /mnt ext4 defaults 0 0

# add an entry to /etc/crypttab. This can be as simple as: SECRET /dev/sdc12

#SECRET ​/dev/sdc12
