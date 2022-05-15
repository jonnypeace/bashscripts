#!/bin/bash

#Tested on SATA and SAS drives. Doesn't work in ZFS using tune2fs. This script will attempt to re-write zero's to the bad LBA_Sector blocks.
#The reason for this is to test the HDD and clear smart errors. If the blocks cant be written to, chances are it'll need replaced.

#Getting device info
read -p "Device for checking (i.e /dev/sdb): " device
#Getting current pending sector count value for info
sect=$(sudo smartctl -A "$device" | grep Current_Pending_Sector | awk '{print $10}')
#Getting the first self test of the LBA error, #1
val=$(sudo smartctl -l selftest "$device" | grep "# 1" | awk '{print $10}')
echo -e "\nCurrent_Pending_Sector Count = $sect\nLBA_of_first_error = $val\n"
read -p "Is this a HEX value (HEX example 0x021d9f44) (y/n) ? " ans

#Checking if it's a hexidecimal or decimal value
if [[ "$ans" =~ ^(yes|y)$ ]]; then
	hexnum="$val"
	decnum=$(( 16#"$hexnum" ))
	echo -e "\nHex Value = $hexnum & Decimal Value = $decnum\n"
	sleep 2; else
	decnum="$val"
	echo -e "\nDecimal Value = $decnum\n"
	sleep 2
fi

#https://www.rapidtables.com/convert/number/hex-to-decimal.html

#Find STARTING block for partition. If multiple partitions, select the partition that
#falls between the the start and end blocks.
sudo fdisk -lu "$device"
echo -e "\n"
read -p "Partition for device where block will be found (example /dev/sdb2)? " part
S=$(sudo fdisk -lu "$device" | grep "$part" | awk '{print $2}')

#Determine if a file is located on this block
echo -e "\ndebugfs HOW TO:\ndebugfs:  open $part\ndebugfs:  testb $decnum\nType q to quit.\nIf block is in use read through script instructions, or reference this website\nhttps://www.smartmontools.org/wiki/BadBlockHowto\n"
sudo debugfs

read -p "Proceed with script? (If block is in use, see link above) y/n: " good
if [[ "$good" =~ ^(yes|y)$ ]]; then
	echo "Proceeding with script"; else
	echo "Exiting Script"
	exit 0
fi
#debugfs:  open /dev/sdX1
#debugfs:  testb 2269012
#Block 2269012 not in use

##############################################
#If, on the other hand, the block is in use, we want to identify the file that uses it:

#debugfs:  testb 2269012
#Block 2269012 marked in use
#debugfs:  icheck 2269012
#Block   Inode number
#2269012 41032
#debugfs:  ncheck 41032
#Inode   Pathname
#41032   /S1/R/H/714197568-714203359/H-R-714202192-16.gwf

#In this example, you can see that the problematic file (with the mount point included in the path) is: /data/S1/R/H/714197568-714203359/H-R-714202192-16.gwf

#When we are working with an ext3 file system, it may happen that the affected file is the journal itself. Generally, if this is the case, the inode number will be very small. In any case, debugfs will not be able to get the file name:

#debugfs:  testb 2269012
#Block 2269012 marked in use
#debugfs:  icheck 2269012
#Block   Inode number
#2269012 8
#debugfs:  ncheck 8
#Inode   Pathname
#debugfs:

#To get around this situation, we can remove the journal altogether:

#tune2fs -O ^has_journal /dev/hda3

#and then start again with Step Four: we should see this time that the wrong block is not in use any more. If we removed the journal file, at the end of the whole procedure we should remember to rebuild it:

#tune2fs -j /dev/hda3

#Fifth Step NOTE: This last step will permanently and irretrievably destroy the contents of the file system block that is damaged: if the block was allocated to a file, some of the data that is in this file is going to be overwritten with zeros. You will not be able to recover that data unless you can replace the file with a fresh or correct version.

##############################################

#Getting block size. ext4 is 4096
B=$(sudo tune2fs -l "$part" | grep "Block size:" | awk '{print $3}')

#In this case the block size is 4096 bytes. Third Step: we need to determine which
#File System Block contains this LBA. The formula is:

#  b = (int)((L-S)*512/B)
#where:
#b = File System block number
#S = Starting sector of partition as shown by fdisk -lu
#read -p "File system partition START block size in bytes: " S
#L = LBA of bad sector
L="$decnum"
#B = File system block size in bytes
#and (int) denotes the integer part. Bash naturally uses an integer unless bc -l is used.

#Calculating the file system block number
b=$(( (("$L"-"$S")*512)/"$B" ))
echo -e "\nFile System Block Number Calculation: (($L-$S)*512)/$B"
echo -e "File System Block Number: $b\n"

#Note: A fractional part over the integer, i.e. 0.125 indicates that this problem LBA
#is actually the second of the eight sectors that make up this file system block.

#Correct block or leave alone?
read -p "Write over block (y/n)? " ans

if [[ "$ans" =~ ^(yes|y)$ ]]; then
	sudo dd if=/dev/zero of="$part" bs="$B" count=1 seek="$b"
	sync
	echo -e "\nMight need to run a smartctl -t (short/long/offline) $part to refresh current pending sector counts"; else
	echo "Block ignored"
fi

#If you get an error using dd, we might need to use hdparm. This part of the
#script has not be developed

#Examples...

# hdparm --read-sector 16782858 /dev/sda

#And when you've confirmed the sector is indeed unreadable,
#use hdparm to write to that sector:

# hdparm --write-sector 16782858 /dev/sda

#####################################################

# Quick one line while loop to make sure follow success of operation, be sure to change the
# X in /dev/sdX. First of all, run a test. smartctl -t long /dev/sdX, then...
# while true; do sudo smartctl -a /dev/sdX | grep -A 1 "Self-test execution status:" ; sleep 10 ; done
# Whether successful or unsuccessful Ctrl+c will cancel the while loop.
