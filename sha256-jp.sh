#!/bin/bash

# Example Use:

# /sha256-jp.sh -s '539a2acd3a921f76f08c759058a12c7fa97e1e1e4956ad6389f25fd4f3c3085b' -f proxmox-ve_7.3-1.iso

while getopts s:f:h opt
do
	case "$opt" in
		s) sums="$OPTARG" ;;
		f) filename="$OPTARG" ;;
		h) echo "
		Help:

		select -s sha256sum value from iso website
		select -f for the actual filename of the iso downloaded
		select -h for this help
		" ;;
		*) exit
	esac
done

# Not required, for just one iso
# shift $(( OPTIND - 1 ))

if [[ -z $sums || -z $filename ]] ; then exit ; fi

if [[ $(sha256sum -b "$filename" | cut -d ' ' -f1) == "$sums" ]]
then
  echo 'We are good, sha sum check passed'
else
  echo 'ISO failed sha sum check'
fi
