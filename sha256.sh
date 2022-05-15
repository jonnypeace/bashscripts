#!/bin/bash
#This script will probably grow with the different hash checks, but for now it works on
#on the distributions i'm using... short and to the point, and i hope self explanatory.
################################

#Instructions for the unaware.
#$1 is a command line variable. So when you ./sha256.sh in terminal, follow this by the
#name of the iso you want to check,i.e. ./sha256.sh proxmox.4.5.6.iso (the iso will be $1)
#copy the sha256sum text from the website to check against.

read -p "iso text from website to check against: " check
sha=$(sha256sum -b $1 | cut -d' ' -f1)
if [ "$check" = "$sha" ]
	then echo "ISO check passed"
	else echo "ISO check failed"
fi
