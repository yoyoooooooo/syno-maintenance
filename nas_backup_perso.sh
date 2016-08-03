#!/bin/sh
#PATH=/bin:/usr/bin:/usr/syno/bin # rsync est dans /usr/syno/bin

mirrorDiskUUID="0019d2dcf"

srcBase="/volume1/"
folders="documents photo video"
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
	
		destBase="$destMountingPoint/nas_backup_perso/"
		
		# Create destBase directory if necessary
		mkdir -p $destBase
		chmod 777 $destBase
	
		# Delete log
		rm $destBase$logFile
		
		date=`date "+%Y%m%d%H%M%S"`
		tempSuffix=_partial
		errorSuffix=_error
		
		mkdir -p $destBase$date$tempSuffix
		chmod 777 $destBase$date$tempSuffix
		
		curdir=current
		
		error=0
		
		# Sync each folder
		for folder in $folders; do
		rsync -rltDvvhP --stats --delete --delete-excluded --exclude-from '/volume1/syno-maintenance/exclude_nas_backup_perso.txt' --chmod=ugo=rwX --log-file=$destBase$logFile --link-dest="$destBase$curdir/$folder" "$srcBase$folder/" "$destBase$date$tempSuffix/$folder"
		((error=error+$?))
		done
		
		if [ $error -eq 0 ]
		then
			mv "$destBase$date$tempSuffix" "$destBase$date"
			rm -f "$destBase$curdir"
			ln -s "$destBase$date" "$destBase$curdir"
			synodsmnotify admin "Backup successful!" "Backup of personal documents successfully completed on external USB volume."
		else
		  	mv "$destBase$date$tempSuffix" "$destBase$date$errorSuffix"
		  	synodsmnotify admin "Backup failed" "Backup of personal documents on external USB volume failed. Check logs."
		fi
	fi
done