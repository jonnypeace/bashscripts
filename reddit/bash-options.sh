#!/bin/bash

# Sense check
function sense_check {
  for i in $* ; do
    test=$(printf '%s' "$i" | wc -m)
    if (( test != 2 )) || [[ ! $i =~ -s|-c|-v|-r|-l|-f|-a|-m|-o|-A ]]; then
      echo "Failed sense check - incorrect flag = $i"
      exit
    fi
  done
}
sense_check "$*"

# Build an array for flags and description
declare -A flagTask

flagTask[-s]='Update system'
flagTask[-c]='Clean Temp Files'
flagTask[-v]='Check for malware (ClamAV)'
flagTask[-r]='Check for rootkits (RKHunter)'
flagTask[-l]='Remove old log files'
flagTask[-f]='Check/Repair file system errors'
flagTask[-a]='Clean up apt cache'
flagTask[-m]='Drop memory cache/buffers'
flagTask[-o]='Optimize disk usage'
flagTask[-A]='ALL TASKS'

# take flags as input from the commandline
input_tasks="$*"
input_tasks="${input_tasks:-all}"

# build an array with boolean values
# Doesn't need to be an array, but wasn't sure whether i'd cycle through them or not.
declare -A sys

function all_true {
  sys[update]=True
  sys[clean]=True
  sys[malware]=True
  sys[rootkit]=True
  sys[log]=True
  sys[fsck]=True
  sys[aptclean]=True
  sys[mem]=True
  sys[disk]=True
}

# main function checking condition of boolean values above to run run_commands
function run_commands {
  if [[ ${sys[update]} == True ]]; then
    echo 'apt update'
  fi
  if [[ ${sys[clean]} == True ]]; then
    echo 'clean temp'
  fi
  if [[ ${sys[malware]} == True ]]; then
    echo 'malware'
  fi
  if [[ ${sys[rootkit]} == True ]]; then
    echo 'rootkit'
  fi
  if [[ ${sys[log]} == True ]]; then
    echo 'clean logs'
  fi
  if [[ ${sys[fsck]} == True ]]; then
    echo 'file systemcheck'
  fi
  if [[ ${sys[aptclean]} == True ]]; then
    echo 'apt clean'
  fi
  if [[ ${sys[mem]} == True ]]; then
    echo 'memory'
  fi
  if [[ ${sys[disk]} == True ]]; then
    echo 'disk'
  fi
}

echo

# Function for selecting the correct flags. Default=all
function selected_flag {
  all_true
  # loop through flag list and check if all or specific flags match
  for flag in "${!flagTask[@]}"; do
    if [[ $input_tasks != 'all' ]]; then
      if [[ $input_tasks =~ $flag ]]
      then
        # These flag checks are for in case you are not happy with selection
        if [[ $flag =~ -A ]]; then all_true ; fi
        if [[ $flag =~ -s ]]; then sys[update]=True ; fi
        if [[ $flag =~ -c ]]; then sys[clean]=True ; fi
        if [[ $flag =~ -v ]]; then sys[malware]=True ; fi
        if [[ $flag =~ -r ]]; then sys[rootkit]=True ; fi
        if [[ $flag =~ -l ]]; then sys[log]=True ; fi
        if [[ $flag =~ -f ]]; then sys[fsck]=True ; fi
        if [[ $flag =~ -a ]]; then sys[aptclean]=True ; fi
        if [[ $flag =~ -m ]]; then sys[mem]=True ; fi
        if [[ $flag =~ -o ]]; then sys[disk]=True ; fi
        printf '\t[\e[32m\u2713 \e[0m]\t%s\t%s\n' "$flag" "${flagTask[$flag]}"
      else
      # if not all and flags not required, then set to false if flags match
        if [[ $flag =~ -s ]]; then sys[update]=False ; fi
        if [[ $flag =~ -c ]]; then sys[clean]=False ; fi
        if [[ $flag =~ -v ]]; then sys[malware]=False ; fi
        if [[ $flag =~ -r ]]; then sys[rootkit]=False ; fi
        if [[ $flag =~ -l ]]; then sys[log]=False ; fi
        if [[ $flag =~ -f ]]; then sys[fsck]=False ; fi
        if [[ $flag =~ -a ]]; then sys[aptclean]=False ; fi
        if [[ $flag =~ -m ]]; then sys[mem]=False ; fi
        if [[ $flag =~ -o ]]; then sys[disk]=False ; fi
        printf '\t[\e[31m\u2718 \e[0m]\t%s\t%s\n' "$flag" "${flagTask[$flag]}"
      fi
    else
      #all_true
      printf '\t[\e[32m\u2713 \e[0m]\t%s\t%s\n' "$flag" "${flagTask[$flag]}"
    fi
  done
  echo
}

# Initial run of the selected_flag function
selected_flag

# always true loop to check you are happy with selection
while true; do

  read -rp 'Are you happy with the selection? (y/N) ' ans

# Checking if happy with the selection, default is no
  if [[ ! ${ans:=N} =~ ^[yY][eE]?[sS]?$ ]]; then
    echo
    for i in "${!flagTask[@]}" ; do echo "$i ${flagTask[$i]}"; done
    echo
    read -rp 'Please enter new selection ' input_tasks
    sense_check "$input_tasks"
    echo
    selected_flag
  else
    break
  fi
done
# Run main function with selection
echo
run_commands
echo
