#!/bin/sh
#PATH=/bin:/usr/bin:/usr/syno/bin # rsync est dans /usr/syno/bin

mirrorDiskUUID="2b6b28bdb"

srcBase="/volume1/"
folders="backup documents music photo soft video"
logFile="rsync.log"

maxUSBId=2
for i in `seq 1 $maxUSBId`
do
	destMountingPoint="/volumeUSB$i/usbshare"
	
	# Retrieve device corresponding to selected mounting point
	dev=$( df | grep $destMountingPoint | awk '{ print $1 }' )
	
	# Check device and UUID match
	count=$( hdparm -I $dev | grep "Unique ID" | grep -ic $mirrorDiskUUID )
	if [ $count -eq 1 ]; then
	
		destBase="$destMountingPoint/nas_mirror/"
		
		# Create destBase directory if necessary
		mkdir -p $destBase
		chmod 777 $destBase
	
		# Delete log
		rm $destBase$logFile
		
		# Sync each folder
		for d in $folders; do
		rsync -avvh --stats --delete --delete-excluded --exclude-from '/volume1/documents/Scripts divers/exclude_nas_mirror.txt' --chmod=ugo=rwX --log-file=$destBase$logFile "$srcBase$d/" "$destBase$d"
		chmod 777 "$destBase$d"
		done
	fi
done