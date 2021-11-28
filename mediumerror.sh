#!/usr/bin/env bash

echo '' > medtemp.txt
cat /dev/null > medtemp.txt

a=1
for ((i=2; i<=5; i++)); do 
	smartctl -a /dev/pass$i | grep "Serial number" >> medtemp.txt; smartctl -a /dev/pass$i | grep "Non-medium error" >> medtemp.txt
	a=$((a+1))
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
