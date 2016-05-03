find /volume1 -name "@eaDir" -type d -print | while read foldername ; do rm -rfv "$foldername" ; done

synodsmnotify admin "@eaDir deletion completed" "All @eadir directories have been deleted from Volume1."