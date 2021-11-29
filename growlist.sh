#!/usr/bin/env bash

#Script written for TrueNAS and SAS drives

#Create empty file to store present data
echo '' > growtemp.txt
cat /dev/null > growtemp.txt

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

for ((i=2; i<=5; i++)); do 
	smartctl -a /dev/pass$i | grep "Serial number" >> growtemp.txt; smartctl -a /dev/pass$i | grep -i "Elements in grown defect list" >> growtemp.txt
done

#Check previous disk health

a=2
for ((i=2; i<=8; i=i+2)); do
	disk=$(awk "NR==$i"'{print $6}' growlist.txt)
	diskC=$(awk "NR==$i"'{print $6}' growtemp.txt)
	scalc=$(( $i-1 ))
	serial=$(awk "NR==$scalc"'{print $3}' growlist.txt)
	if [[ $disk -lt $diskC ]]; then
		diff=$(( "$diskC" - "$disk" ))
		echo "***** disk $serial Elements in Grown Defect List has increased by $diff *****"; else
		echo "disk $serial Grown Defect List are ok"
	fi
	a=$((a+1))
done
