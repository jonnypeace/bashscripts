#!/bin/bash

apass=$(sudo smartctl -H /dev/sda | awk 'NR==5{print $2":", $6}')
adrive=$(sudo smartctl -A /dev/sda | awk '/Current_Pending_Sector/{print $2":", $10}/Reallocated_Event_Count/{print $2":", $10}/Offline_Uncorrectable/{print $2":", $10}' | paste -sd " ")

testmount1=$(df -h | awk '/\/drive1/{print $6}')
if [[ -e $testmount1 ]] ; then
  echo -e "drive1 drive already mounted & $apass & $adrive" ; else
  mount /3tb1
  echo -e "drive1 drive mounted & $apass & $adrive" ;
fi

bpass=$(sudo smartctl -H /dev/sdb | awk 'NR==5{print $2":", $6}')
bdrive=$(sudo smartctl -A /dev/sdb | awk '/Current_Pending_Sector/{print $2":", $10}/Reallocated_Event_Count/{print $2":", $10}/Offline_Uncorrectable/{print $2":", $10}' | paste -sd " ")

testmount2=$(df -h | awk '/\/drive2/{print $6}')
if [[ -e $testmount2 ]] ; then
  echo -e "drive2 drive already mounted & $bpass & $bdrive" ; else
  mount /3tb2
  echo -e "drive2 drive mounted & $bpass & $bdrive" ;
fi
