#!/usr/bin/env bash

#Script written for TrueNAS

#Create empty file to store present data
echo '' > medtemp.txt
cat /dev/null > medtemp.txt

#Present Baseline file to compare data against.
read -p "Create baseline data? Warning, will recreate baseline data file with present data [y/n] : " ans
if [[ $ans =~ ^(yes|y)$ ]]; then
	echo '' > serialMediumErrors.txt
	cat /dev/null > serialMediumErrors.txt
	smartctl --scan
	read -p "Start drive number, i.e. /dev/pass2. 2 would be the start numnber: " start
	read -p "Last drive number, i.e /dev/pass5. 5 would be the last number: " last
	for ((i=$start; i<=$last; i++)); do
	smartctl -a /dev/pass$i | grep "Serial number" >> serialMediumErrors.txt; smartctl -a /dev/pass$i | grep "Non-medium error" >> serialMediumErrors.txt
	done
fi

for ((i=2; i<=5; i++)); do 
	smartctl -a /dev/pass$i | grep "Serial number" >> medtemp.txt; smartctl -a /dev/pass$i | grep "Non-medium error" >> medtemp.txt
done

#Check previous disk health

a=2
for ((i=2; i<=8; i=i+2)); do
	disk=$(awk "NR==$i"'{print $4}' serialMediumErrors.txt)
	diskC=$(awk "NR==$i"'{print $4}' medtemp.txt)
	scalc=$(( $i-1 ))
	serial=$(awk "NR==$scalc"'{print $3}' serialMediumErrors.txt)
	if [[ $disk -lt $diskC ]]; then
		diff=$(( "$diskC" - "$disk" ))
		echo "***** disk $serial medium error count has increased by $diff *****"; else
		echo "disk $serial medium errors are ok"
	fi
	a=$((a+1))
done
