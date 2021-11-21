#!/bin/bash

#Quick script for synchronising backups, looking up drive health before it could potentially
#write bad data and vice versa. I use this in a crontab which emails (you'll have to set that up manually)
#the output.

###############################
# THIS SCRIPT NEEDS TO INCLUDE SOME MORE DATA FOR CHECKING SAS DRIVES... AND MAYBE SATA, IT'S A WORK IN PROGRESS.
###############################

#Set up the drives for synchronizing. I use /dev/sda as my shared network drive - NEITHER DRIVE IS MY ROOT DIRECTORY.
#I've only tested on storage drives outside the root file system. This checks smartmontools for the overall-health of the drives.
n=$(sudo smartctl -a /dev/sda | grep "PASSED")
m=$(sudo smartctl -a /dev/sdb | grep "PASSED")
if [[ ( $n == "SMART overall-health self-assessment test result: PASSED" ) && ( $m == "SMART overall-health self-assessment test result: PASSED" ) ]]
#then echo "GOOD HEALTH"
#/media/drive1 and /media/drive2 will be which ever storage drives you've mounted for rsync.
 then
 rsync -ahv --delete-after /media/drive1 /media/drive2
 echo "sync completed"
 else 
 echo "BAD HEALTH"
fi
