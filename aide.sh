#!/bin/bash

database=/var/lib/aide/aide.db
databasenew=/var/lib/aide/aide.db.new
conf=/home/jonny/aide.conf

function updatedb {
  sudo aide -c "$conf" --init
  sudo cp -v "$databasenew" "$database"
}

function checkdb {
  sudo aide -c "$conf" --check
}

cat << EOF

  Select number for aide to....
	  
  1) Update database?
  2) Check database?

EOF

read ans

case "$ans" in
	1)
		updatedb ;;
	2)
		checkdb ;;
	*)
		echo "Invalid Selection, exiting....."
esac
