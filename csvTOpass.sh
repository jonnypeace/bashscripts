#!/bin/bash

#The purpose for this script is to convert keepass .csv files into pass... a linux password manager which can later be used
#with passmenu which uses dmenu for passwords - overall, i find pass, passmenu (with dmenu) and pass otp aids in a better
#user experience using keybindings. It takes a little bit of configuring with the csv file.....
#My CSV files are formatted like so...
# website,user,password
# google,jonny,password123
# This script will not work well if you have additional entries.
# As you'll see below, my CSV file is called forPass.csv and is located /home/user/Documents

echo
echo -e "Is your CSV file formatted like so....\n\nwebsite,user,password\nLocated in /home/user/Documents\nFile named forPass.csv? [y/n] : "
read ans
if [[ $ans =~ ^(yes|y)$ ]]; then

data=$HOME/Documents/forPass.csv
i=0
array=()

while IFS="" read -r p
do
  array[i]=$(printf '%s\n' "$p")
  i=$(( i + 1 ))
done < $data

i=0
bulk=0
notbulk=0

for user in "${array[@]}"
do
  newsite=$(awk -F "," '{print $1}' <<< "${array[i]}")
  newuser=$(awk -F "," '{print $2}' <<< "${array[i]}")
  newpass=$( sed -e 's/,/ /1' -e 's/,/ /1' <<< "${array[i]}" | awk '{print $3}' )
  try=$(echo $newpass | awk -F "" '{print $NF}')
  if [[ $try == "," ]]; then
    read -p "Comma detected at end of $newsite/$newuser line in csv file, proceed? [y/n]? " check
    if [[ $check =~ ^(yes|y)$ ]]; then
      try=$( echo $newpass | sed -e 's/.$//' | awk -F "" '{print $1$NF}')
      if [[ $try != '""' ]] ; then
        newpass=$( echo $newpass | sed -e 's/.$//' )
        (echo $newpass) | pass add --echo -e $newsite/$newuser
        i=$(( i + 1 ))
      else
	      newpass=$( echo $newpass | sed -e 's/..$//' -e '1s/^.//' )
	      (echo $newpass) | pass add --echo -e $newsite/$newuser
	      i=$(( i + 1 ))
      fi
    fi ; else
    try=$( echo $newpass | awk -F "" '{print $1$NF}')
    if [[ $try == '""' ]]; then
      newpass=$( echo $newpass | sed -e 's/.$//' -e '1s/^.//' )
      (echo $newpass) | pass add --echo -e $newsite/$newuser
      notbulk=$(( $notbulk + 1 ))
      i=$(( i + 1 ))
    else
      (echo $newpass) | pass add --echo -e $newsite/$newuser
      i=$(( i + 1 ))
      bulk=$(( $bulk + 1 ))
    fi
 fi
done; else
echo "Script stopped until CSV is formatted correctly"
fi
echo bulk equal $bulk and notbulk equals $notbulk
