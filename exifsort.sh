#!/bin/bash

# This script was written in order to organise my picture files by year.
# The reason behind this, after a bulk download of my images from flickr,
# I had lost the original file creation dates, so sorting was not as simple.
# Hopefully someone else finds this script helpful, and feel free to contact
# if there's a bug or better way of doing this.
# Originally i hard coded all the years and still have this script if needed, 
# but felt something a little more dynamic might be better.

#### IMPORTANT : For this script to work, you will have to apt install exif ####

read -p "Enter start year for pictures: " start
read -p "Enter final year for pictures: " final
read -p "Full path directory for scanning. (example format.. /home/user/pictures ): " folder

yeardif=$(( $final - $start + 1 ))
groups=()

i=1

for year in $(seq $start $final) ;
	do
	groups[i]="$folder/$year/"
	mkdir -p "${groups[i]}"
	i=$(( i + 1 ))
	done

casedata=$( printf '%s\n' "${groups[@]}" | sed 's/.*\(.....\)/\1/' | cut -d "/" -f1 | sed -e 's/$/|/' | awk '{ for (i=1; i<=NF; i++) a[i]= (a[i]? a[i] $i: $i) } END{ for (i in a) print a[i] }' | sed 's/.$//' )

echo -e "\nPicture file sorting in progress...."

#loop through each file in folder for scanning

for f in "$folder"/*.jpg "$folder"/*.jpeg ;
	do
	data=$(exif $f 2> /dev/null | grep "Date and Time (Origi" | cut -d "|" -f 2 | cut -d " " -f 1 | awk -F ":" 'NR==1{print $1}')

#if the grep info is not Origi, then the data variable won't have a value,
#but there is another row we can check that will still be close...

	case $data in
	 $casedata) echo -n '' ;;
	 *) data=$(exif $f 2> /dev/null | grep "Date and Time" | cut -d "|" -f 2 | cut -d " " -f 1 | awk -F ":" 'NR==1{print $1}') ;;
	esac

#By now the grep should be successful. If the directory already exists, no error will occur, nor will the directory be over-written.

#The directory the file will be moved to will be based on the year the image was taken.

	for (( i = 1; i <= $yeardif; i++ )) ;
	 do
	 year=$( echo "${groups[i]}" | sed 's/.*\(.....\)/\1/' | cut -d "/" -f1 )
	 pathto="${groups[i]}"
	 case $data in

		$year)
		mv $f $pathto
		;;

		*)
		echo -n ""
		;;
	 esac
	done
done
echo "Cleaning empty directories"
for d in "${groups[@]}" ;
	do
	if [ "$( ls -A $d )" ]
	then echo "$d in use"
	else echo "$d is empty"
	rm -r $d
	fi
done
echo -e "\nexif loop complete.\nAny picture files remaining most likely do not have exif data, but may also contain spaces in the filename.\nCheck filenames for spaces. Also check if file extensions are supported.\n\nExtensions included in this script are; jpg jpeg\n"
