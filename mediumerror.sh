#!/usr/bin/env bash

#Script written for TrueNAS & SAS drives to check for Elements in grown defect list, create a baseline and compare against present data.

#temporary files for present data
medtemp=$(mktemp -t medtemp.XXXXXX)

#Baseline file to compare data against.
read -p "Create baseline data? Warning, will recreate baseline data file with present data [y/n] : " ans
smartctl --scan
read -p "Start drive number, i.e. /dev/pass2. 2 would be the start number: " start
read -p "Last drive number, i.e /dev/pass5. 5 would be the last number: " last

if [[ $ans =~ ^(yes|y)$ ]]; then
	echo '' > serialMediumErrors.txt
	cat /dev/null > serialMediumErrors.txt
	for ((i=$start; i<=$last; i++)); do
	smartctl -a /dev/pass$i | grep "Serial number" >> serialMediumErrors.txt; smartctl -a /dev/pass$i | grep "Non-medium error" >> serialMediumErrors.txt
	done
fi

for ((i=$start; i<=$last; i++)); do 
	smartctl -a /dev/pass$i | grep "Serial number" >> $medtemp; smartctl -a /dev/pass$i | grep "Non-medium error" >> $medtemp
done

#Check previous disk health
maxnum=$(( ("$start"-"$last"+1)*2 ))

for ((i=$start; i<="$maxnum"; i=i+2)); do
	disk=$(awk "NR==$i"'{print $4}' serialMediumErrors.txt)
	diskC=$(awk "NR==$i"'{print $4}' $medtemp)
	scalc=$(( $i-1 ))
	serial=$(awk "NR==$scalc"'{print $3}' serialMediumErrors.txt)
	if [[ $disk -lt $diskC ]]; then
		diff=$(( "$diskC" - "$disk" ))
		echo "***** disk $serial medium error count has increased by $diff *****"; else
		echo "disk $serial medium errors are ok"
	fi
done

rm $medtemp
