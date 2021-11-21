#!/bin/bash

#This is a work in progress for users other than myself. If you understand the code, feel free to modify for your own needs.
#The purpose for this script is to convert keepass .csv files into pass... a linux password manager which can later be used
#with passmenu which uses dmenu for passwords - overall, i find pass, passmenu (with dmenu) and pass otp aids in a better
#user experience using keybindings. It takes a bit of configuring with the csv file, and this code patches a few errors which
#might not work with you. I.e. If you are correctly using long and complicated passwords, with comma's.... my script has been patched
#to work with only ONE COMMA IN THE PASSWORD.

data=$HOME/Documents/forPass.csv
i=1
array=()

while IFS="" read -r p || [ -n "$p" ]
do
  array[i]=$(printf '%s\n' "$p")
  i=$(( i + 1 ))
done < $data

i=1

for user in "${array[@]}"
  do
  newsite=$(awk -F "," '{print $1}' <<< "${array[i]}")
  newuser=$(awk -F "," '{print $2}' <<< "${array[i]}")
  newpass=$(awk -F "," '{print $3}' <<< "${array[i]}")
  newpcon=$(awk -F "," '{print $4}' <<< "${array[i]}")
  if [ -z $newpcon ]
   then
    (echo "$newpass"; echo "$newpass") | pass add --echo -e "$newsite/$newuser"
   else
   newpp=$(sed -e 's/.$//'  <<< "$newpass,$newpcon" | sed -e 's/^.//')
   (echo "$newpp"; echo "$newpp") | pass add --echo -e "$newsite/$newuser"
   fi
  i=$(( i + 1 ))
done
