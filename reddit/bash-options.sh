#!/bin/bash

# User on reddit looking for a way to run health checks on system
# Author: Jonny Peace
# run as....
# ./script.sh
# or with flags
# ./script.sh -l -o 

# Currently no worthwhile commands really run, run_commands an empty function to do as you please.

# Sense check
function sense_check {
  for i in "$@" ; do
    test=$(printf '%s' "$i" | wc -m)
    if (( test != 2 )) || [[ ! $i =~ -s|-c|-v|-r|-l|-f|-a|-m|-o|-A ]]; then
      echo "Failed sense check - incorrect flag = $i"
      exit
    fi
  done
}
sense_check "$@"

# build an array with boolean values
declare -A flagTask

function all_true {
  for i in -s -c -v -r -l -f -a -m -o -A; do
    flagTask[$i]=True
  done
}

# Build an array for flags and description
declare -A flagInfo
flagInfo[-s]='Update system'
flagInfo[-c]='Clean Temp Files'
flagInfo[-v]='Check for malware (ClamAV)'
flagInfo[-r]='Check for rootkits (RKHunter)'
flagInfo[-l]='Remove old log files'
flagInfo[-f]='Check/Repair file system errors'
flagInfo[-a]='Clean up apt cache'
flagInfo[-m]='Drop memory cache/buffers'
flagInfo[-o]='Optimize disk usage'
flagInfo[-A]='ALL TASKS'

# take flags as input from the commandline
input_tasks="$*"
input_tasks="${input_tasks:-all}"

# main function checking condition of boolean values above to run run_commands
# Needs modified to suit user needs
# echo commands are placeholders to show the script works
function run_commands {
  if [[ ${flagTask[-s]} == True ]]; then
    echo 'apt update'
  fi
  if [[ ${flagTask[-c]} == True ]]; then
    echo 'clean temp'
  fi
  if [[ ${flagTask[-v]} == True ]]; then
    echo 'malware'
  fi
  if [[ ${flagTask[-r]} == True ]]; then
    echo 'rootkit'
  fi
  if [[ ${flagTask[-l]} == True ]]; then
    echo 'clean logs'
  fi
  if [[ ${flagTask[-f]} == True ]]; then
    echo 'file systemcheck'
  fi
  if [[ ${flagTask[-a]} == True ]]; then
    echo 'apt clean'
  fi
  if [[ ${flagTask[-m]} == True ]]; then
    echo 'memory'
  fi
  if [[ ${flagTask[-o]} == True ]]; then
    echo 'disk'
  fi
}

echo

# Function for selecting the correct flags. Default=all
function selected_flag {
  all_true
  local print_tick print_cross
  # loop through flag list and check if all or specific flags match
  for flag in "${!flagInfo[@]}"; do
    # shellcheck disable=SC2016
    print_tick='printf "\t[\e[32m\u2713 \e[0m]\t%s\t%s\n" "$flag" "${flagInfo[$flag]}"'
    # shellcheck disable=SC2016
    print_cross='printf "\t[\e[31m\u2718 \e[0m]\t%s\t%s\n" "$flag" "${flagInfo[$flag]}"'
    if [[ $input_tasks != 'all' ]]; then
      if [[ $input_tasks =~ $flag ]]
      then
        if [[ $flag == "-A" ]]; then all_true ; eval "$print_tick" ; continue ; fi
        # These flag checks are for in case you are not happy with selection
        for option in "${!flagTask[@]}"; do
          if [[ $flag == "$option" ]]; then flagTask[$option]=True ; eval "$print_tick" ; continue ; fi
        done
      else
        for option in "${!flagTask[@]}"; do
          if [[ $flag == "$option" ]]; then flagTask[$option]=False ; eval "$print_cross" ; continue ; fi
        done
      # if not all and flags not required, then set to false if flags match
      fi
    else
      eval "$print_tick"
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
    read -rp 'Please enter new selection ' input_tasks
    # shellcheck disable=SC2086
    sense_check $input_tasks
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
