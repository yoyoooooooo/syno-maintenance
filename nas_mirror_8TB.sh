#!/bin/sh
#PATH=/bin:/usr/bin:/usr/syno/bin # rsync est dans /usr/syno/bin

mirrorDiskUUID="0cc809392"

srcBase="/volume1/"
folders="backup books documents music photo soft video syno-maintenance"
logFile="rsync.log"

maxUSBId=10
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
		
		error=0
		
		# Sync each folder
		for d in $folders; do	
		rsync -avvh --stats --delete --delete-excluded --exclude-from '/volume1/syno-maintenance/exclude_nas_mirror.txt' --chmod=ugo=rwX --log-file=$destBase$logFile "$srcBase$d/" "$destBase$d"
		((error=error+$?))
		chmod 777 "$destBase$d"
		done
		
		if [ $error -eq 0 ]
		then
			synodsmnotify admin "NAS mirroring successful!" "NAS mirroring successfully completed on external USB volume."
		else
		  	synodsmnotify admin "NAS mirroring failed" "NAS mirroring on external USB volume failed. Check logs."
		fi
	fi
done
synodsmnotify admin "Mirroring end" "Mirroring task exited."