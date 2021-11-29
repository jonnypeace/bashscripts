#!/usr/bin/env bash

#Script written for TrueNAS & SAS drives to check for Elements in grown defect list, create a baseline and compare against present data.

#temporary file for present data
growtemp=$(mktemp -t growtemp.XXXXXX)

#Baseline file to compare data against.
read -p "Create baseline data? Warning, will recreate baseline data file with present data [y/n] : " ans
if [[ $ans =~ ^(yes|y)$ ]]; then
	echo '' > growlist.txt
	cat /dev/null > growlist.txt
	smartctl --scan
	read -p "Start drive number, i.e. /dev/pass2. 2 would be the start numnber: " start
	read -p "Last drive number, i.e /dev/pass5. 5 would be the last number: " last
	for ((i=$start; i<=$last; i++)); do
	smartctl -a /dev/pass$i | grep "Serial number" >> growlist.txt; smartctl -a /dev/pass$i | grep -i "Elements in grown defect list" >> growlist.txt
	done
fi

read -p "Number of drives to check? " num
maxnum=$(( $num+1 ))

for ((i=2; i<="$maxnum"; i++)); do 
	smartctl -a /dev/pass$i | grep "Serial number" >> $growtemp; smartctl -a /dev/pass$i | grep -i "Elements in grown defect list" >> $growtemp
done

#Check previous disk health
maxnum=$(( $num*2 ))
a=2
for ((i=2; i<="$maxnum"; i=i+2)); do
	disk=$(awk "NR==$i"'{print $6}' growlist.txt)
	diskC=$(awk "NR==$i"'{print $6}' $growtemp)
	scalc=$(( $i-1 ))
	serial=$(awk "NR==$scalc"'{print $3}' growlist.txt)
	if [[ $disk -lt $diskC ]]; then
		diff=$(( "$diskC" - "$disk" ))
		echo "***** disk $serial Elements in Grown Defect List has increased by $diff *****"; else
		echo "disk $serial Grown Defect List are ok"
	fi
	a=$((a+1))
done

rm $growtemp
