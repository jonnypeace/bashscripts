#!/bin/bash

#Quick script for synchronising backups, looking up drive health before it could potentially
#write bad data and vice versa. I use this in a crontab which emails (you'll have to set that up manually)
#the output.

###############################
# AT PRESENT, THIS SCRIPT CHECKS A FEW ATTRIBUTES AND OVERALL HEALTH OF SATA DRIVES.
###############################

# Checking health of drive sda
a_pass=$(sudo smartctl -H /dev/sda | awk 'NR==5{print $6}')
a_pend=$(sudo smartctl -A /dev/sda | awk '/Current_Pending_Sector/{print $10}')
a_reall=$(sudo smartctl -A /dev/sda | awk '/Reallocated_Event_Count/{print $10}')
a_uncor=$(sudo smartctl -A /dev/sda | awk '/Offline_Uncorrectable/{print $10}')

# Checking health of drive sdb
b_pass=$(sudo smartctl -H /dev/sdb | awk 'NR==5{print $6}')
b_pend=$(sudo smartctl -A /dev/sdb | awk '/Current_Pending_Sector/{print $10}')
b_reall=$(sudo smartctl -A /dev/sdb | awk '/Reallocated_Event_Count/{print $10}')
b_uncor=$(sudo smartctl -A /dev/sdb | awk '/Offline_Uncorrectable/{print $10}')

# Testing whether the drives are mounted
testmount1=$(df -h | awk '/\/drive1/{print $6}')
testmount2=$(df -h | awk '/\/drive2/{print $6}')

# If drives are not mounted, script will exit.
if [[ -e $testmount1 || -e $testmount2 ]] ; then
  echo drive sda & sdb mounted and testing...
# Checking drive health and attributes are in good condition  
  if [[ $a_pass != PASSED || $a_pend != 0 || $a_reall != 0 || $a_uncor != 0 || $b_pass != PASSED || $b_pend != 0 || $b_reall != 0 || $b_uncor != 0 ]] ; then
# If one of the drives does not conform to the above arguments, no rsync takes place
    echo "Check drive health, might be time to replace one of the drives" ; else
# If both drives pass the arguments, rsync will progress.
# IMPORTANT when using rsync. Syntax for me works best like so.... rsync -options /drive1/ /drive2/ with the slash at the end of your mount point or directory.
    echo "Syncing drives..."
    rsync -avhrxH --delete /drive1/ /drive2/
  fi ; else
  echo "Check drives are mounted correctly, or if drives have failed"
fi
