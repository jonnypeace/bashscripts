#!/bin/bash

#The purpose for this script is to convert keepass .csv files into pass... a linux password manager which can later be used
#with passmenu which uses dmenu for passwords - overall, i find pass, passmenu (with dmenu) and pass otp aids in a better
#user experience using keybindings. It takes a little bit of configuring with the csv file.....
#My CSV files are formatted like so...
# website,user,password
# google,jonny,password123
# This script will not work well if you have additional entries.
# As you'll see below, my CSV file is called forPass.csv and is located /home/user/Documents

echo -e "Is your CSV file formatted like so....\nwebsite,user,password\nLocated in /home/user/Documents\nFile named forPass.csv? [y/n] : "
read ans

if [[ $ans =~ ^(yes|y)$ ]]; then

data=$HOME/Documents/forPass.csv
i=1
array=()

while IFS=, read -r x y z
do
  array[i]=$(printf '%s\n' "$x $y $z")
  i=$(( i + 1 ))
done < $data

i=1

for user in "${array[@]}"
  do
  newsite=$(echo ${array[i]} | cut -d" " -f1)
  newuser=$(echo ${array[i]} | cut -d" " -f2)
  newpass=$(echo ${array[i]} | cut -d" " -f3)
  (echo $newpass) | pass add --echo -e $newsite/$newuser
  i=$(( i + 1 ))
done; else

echo "Script stopped until CSV is formatted correctly"
fi
