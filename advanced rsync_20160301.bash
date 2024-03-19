#!/bin/bash
# advanced rsync script. Mainly for things with millions of inodes.

printf "\nUse ps to monitor rsync.  Cannot show progress due to multi-thread\n\tps -ef | egrep -c \"[0-9] rsync\"\n\n"

date
#################################################################################################################################
# SETUP OPTIONS
#################################################################################################################################

# expect to see 3x this number of processes. Recommend to keep below 16 as all memory will be consumed on rsync server.
export THREADS="32"
export SELF="${0##*/}"
export NOW=$(date +"%F")
export LOGFILE="/rsync/logs/$SELF.log"

export SRCDIR1="/mnt/SOURCE_PATH"
export DSTDIR1="/mnt/DEST_PATH"

#################################################################################################################################
# functions
#################################################################################################################################
<<COMMENT1

rsyncFolders () { 
    export SRCDIR="$1"
    export DSTDIR="$2"
    
    export T="$(date +%s)"
    rsync -ra -f"+ */" -f"- *" $SRCDIR/ $DSTDIR/
    export T="$(($(date +%s)-T))"
    printf "%02d:%02d:%02d:%02d" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"; printf "\t$SRCDIR\t-->\t$DSTDIR\n"
 }

COMMENT1

rsyncAll () { 
    export SRCDIR="$1"
    export DSTDIR="$2"
    export SELF="${0##*/}"
    export NOW=$(date +"%F")
    export LOGFILE="/rsync/logs/$SELF.log"
    
    export T="$(date +%s)"
    rsync -a $SRCDIR/ $DSTDIR/
    #cd $SRCDIR; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -a --inplace % $DSTDIR/%
    export T="$(($(date +%s)-T))"
    printf "\n"
    #printf "%02d:%02d:%02d:%02d" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"; printf "\t$SRCDIR\t-->\t$DSTDIR\n"
    printf "$NOW\tNODELETE\t" | tee -a $LOGFILE
    printf "%02d:%02d:%02d:%02d\t$SRCDIR\t-->\t$DSTDIR\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" | tee -a $LOGFILE
 }

rsyncAlldelete () { 
    export SRCDIR="$1"
    export DSTDIR="$2"
    export SELF="${0##*/}"
    export NOW=$(date +"%F")
    export LOGFILE="/rsync/logs/$SELF.log"
    
    export T="$(date +%s)"
    rsync -a --delete $SRCDIR/ $DSTDIR/
    #cd $SRCDIR; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -a --inplace % $DSTDIR/%
    export T="$(($(date +%s)-T))"
    printf "\n"
    #printf "%02d:%02d:%02d:%02d" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"; printf "\t$SRCDIR\t-->\t$DSTDIR\n"
    printf "$NOW\tDELETE\t" | tee -a $LOGFILE
    printf "%02d:%02d:%02d:%02d\t$SRCDIR\t-->\t$DSTDIR\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" | tee -a $LOGFILE
 }


#################################################################################################################################
# Main
#################################################################################################################################

printf "`date +"%F %R"`\tScript initiated\n" | tee -a $LOGFILE


printf "\nSyncing all\n"
rsyncAll $SRCDIR1 $DSTDIR1 &


<<COMMENT2
printf "\nSyncing all\n"
rsyncAlldelete $SRCDIR1 $DSTDIR1 &
COMMENT2

date

printf "\nNOTE: The last rsync you run during maintenance window should be a manual rsync with the --delete option:\n\n"
printf "\trsync -a --delete --inplace -Ph $SRCDIR1/ $DSTDIR1/\n"