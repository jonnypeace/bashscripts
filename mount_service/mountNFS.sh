#!/bin/bash

apass=$(sudo smartctl -H /dev/sda | awk 'NR==5{print $2":", $6}')
adrive=$(sudo smartctl -A /dev/sda | awk 'BEGIN{ORS=" "}/Current_Pending_Sector/{print $2":", $10}/Reallocated_Event_Count/{print $2":", $10}/Offline_Uncorrectable/{ORS="\n"; print $2":", $10}')

testmount1=$(df -h | awk '/\/drive1/{print $6}')
if [[ -n $testmount1 ]] ; then
  printf '%s\n' "drive1 drive already mounted & $apass & $adrive"
else
  mount /3tb1
  printf '%s\n' "drive1 drive mounted & $apass & $adrive" ;
fi

bpass=$(sudo smartctl -H /dev/sdb | awk 'NR==5{print $2":", $6}')
bdrive=$(sudo smartctl -A /dev/sdb | awk 'BEGIN{ORS=" "}/Current_Pending_Sector/{print $2":", $10}/Reallocated_Event_Count/{print $2":", $10}/Offline_Uncorrectable/{ORS="\n"; print $2":", $10}')

testmount2=$(df -h | awk '/\/drive2/{print $6}')
if [[ -n $testmount2 ]] ; then
  printf '%s\n' "drive2 drive already mounted & $bpass & $bdrive"
else
  mount /3tb2
  printf '%s\n' "drive2 drive mounted & $bpass & $bdrive" ;
fi
