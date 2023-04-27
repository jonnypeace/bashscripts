#!/bin/bash

# Create an array from smartmontools for reference of /dev/sda
mapfile -t sda_health < <(sudo smartctl -a /dev/sda)

# declare associative arrays
declare -A sda sdb

# assign associative array with health info
sda[pass]=$(awk '/overall-health/{print $6}' < <(printf '%s\n' "${sda_health[@]}"))
sda[pend]=$(awk '/Current_Pending_Sector/{print $10}' < <(printf '%s\n' "${sda_health[@]}"))
sda[reall]=$(awk '/Reallocated_Event_Count/{print $10}' < <(printf '%s\n' "${sda_health[@]}"))
sda[uncor]=$(awk '/Offline_Uncorrectable/{print $10}' < <(printf '%s\n' "${sda_health[@]}"))

# Create an array from smartmontools for reference of /dev/sda
mapfile -t sdb_health < <(sudo smartctl -a /dev/sdb)

# assign associative array with health info
sdb[pass]=$(awk '/overall-health/{print $6}' < <(printf '%s\n' "${sdb_health[@]}"))
sdb[pend]=$(awk '/Current_Pending_Sector/{print $10}' < <(printf '%s\n' "${sdb_health[@]}"))
sdb[reall]=$(awk '/Reallocated_Event_Count/{print $10}' < <(printf '%s\n' "${sdb_health[@]}"))
sdb[uncor]=$(awk '/Offline_Uncorrectable/{print $10}' < <(printf '%s\n' "${sdb_health[@]}"))

# Test mounts for both /dev/sda and sdb
testmount1=$(df -h | awk '/\/3tb1/{print $6}')
testmount2=$(df -h | awk '/\/3tb2/{print $6}')

# if both drives are mounted, -n implies the variables contain a string...
if [[ -n $testmount1 && -n $testmount2 ]] ; then

  # Test health conditions for both drives... if drive is in poor health, dont sync.
  # Allow user intervention to investigate data integrity and replace faulty drive.
  
  if [[ ${sda[pass]} != PASSED || ${sda[pend]} != 0 || ${sda[reall]} != 0 || ${sda[uncor]} != 0 ||
          ${sdb[pass]} != PASSED || ${sdb[pend]} != 0 || ${sdb[reall]} != 0 || ${sdb[uncor]} != 0 ]] ; then

    echo "Check drive health, might be time to replace one of the 3tb1 drives" 
    exit 1
  else
    echo "Syncing drives..."
    rsync -avhrxH --delete --backup-dir=/3tb1/backup /3tb1/ /3tb2/
  fi
else
  echo "Check drives are mounted correctly, or if drives have failed"
  exit 1
fi
