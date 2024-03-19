#!/bin/bash
# 
# !!!WARNING!!! 
#   Expect this script to consume all available memory on the server running it.
#   Lowering THREADS to very low numbers can help if server has low memory.

# Setup:
#   rsync server should be dedicated, preferably with 10gb connectivity and vast amounts of non-shared memory (expect all memory to be consumed)
#
#   NFS mounts
#       - Mount as root, otherwise rsync may not be able to copy all attritbutes. 
#       - /etc/fstab example  (should be able to mount source as ro, still as root though)
#           <old_storage_host>:/<source_volume>   /mnt/_vol1__source  nfs  ro,hard,bg,vers=3,sec=sys,tcp,rsize=65536,wsize=65536  0 0
#           <new_storage_host>:/<dest_volume>     /mnt/_vol1__dest    nfs  rw,hard,bg,vers=3,sec=sys,tcp,rsize=65536,wsize=65536  0 0
#
#   Modify SRCDIR and DESTDIR variables as needed.  Should be mounted locally.
#   Modify THREADS as needed. 
#       Generally: 
#           Many small files will benefit from higher threads
#           Many large files will run better with lower threads due to memory exhaustion.

# IF YOU WANT TO LIMIT THE IO PRIORITY, 
# PREPEND THE FOLLOWING TO THE rsync & cd/find COMMANDS ABOVE:
#   ionice -c2

printf "\nUse ps to monitor rsync.  Cannot show progress due to multi-thread\n\tps -ef | egrep -c \"[0-9] rsync\"\n\n"

date
# SETUP OPTIONS
export SRCDIR1="/mnt/_vol1__source"
export DESTDIR1="/mnt/_vol1__dest"
export SRCDIR2="/mnt/_vol2__source"
export DESTDIR2="/mnt/_vol2__dest"
export SRCDIR3="/mnt/_vol3__source"
export DESTDIR3="/mnt/_vol3__dest"
export SRCDIR4="/mnt/_vol4__source"
export DESTDIR4="/mnt/_vol4__dest"
export SRCDIR5="/mnt/_vol5__source"
export DESTDIR5="/mnt/_vol5__dest"
export SRCDIR6="/mnt/_vol6__source"
export DESTDIR6="/mnt/_vol6__dest"
export SRCDIR7="/mnt/_vol7__source"
export DESTDIR7="/mnt/_vol7__dest"

# THREADS PER SRC/DEST -- so 7 volumes would result in 224 processes running.
#   note: a single rsync will have 2-3 threads running.
export THREADS="32"

# RSYNC DIRECTORY STRUCTURE
rsync -zra -f"+ */" -f"- *" $SRCDIR1/ $DESTDIR1/
rsync -zra -f"+ */" -f"- *" $SRCDIR2/ $DESTDIR2/
rsync -zra -f"+ */" -f"- *" $SRCDIR3/ $DESTDIR3/
rsync -zra -f"+ */" -f"- *" $SRCDIR4/ $DESTDIR4/
rsync -zra -f"+ */" -f"- *" $SRCDIR5/ $DESTDIR5/
rsync -zra -f"+ */" -f"- *" $SRCDIR6/ $DESTDIR6/
rsync -zra -f"+ */" -f"- *" $SRCDIR7/ $DESTDIR7/
# FOLLOWING MAYBE FASTER BUT NOT AS FLEXIBLE
# cd $SRCDIR; find . -type d -print0 | cpio -0pdm $DESTDIR/
# FIND ALL FILES AND PASS THEM TO MULTIPLE RSYNC PROCESSES
# cd $SRCDIR; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -az % $DESTDIR/% 
cd $SRCDIR1; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -a --inplace % $DESTDIR1/%
sleep 1
cd $SRCDIR2; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -a --inplace % $DESTDIR2/%
sleep 1
cd $SRCDIR3; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -a --inplace % $DESTDIR3/%
sleep 1
cd $SRCDIR4; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -a --inplace % $DESTDIR4/%
sleep 1
cd $SRCDIR5; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -a --inplace % $DESTDIR5/%
sleep 1
cd $SRCDIR6; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -a --inplace % $DESTDIR6/%
sleep 1
cd $SRCDIR7; find . -type f -print0 | xargs -0 -n1 -P$THREADS -I% rsync -a --inplace % $DESTDIR7/%

date

#rsync -a --delete --inplace -Ph $SRCDIR1/ $DESTDIR1/
#rsync -a --delete --inplace -Ph $SRCDIR2/ $DESTDIR2/

printf "\nNOTE: The last rsync you run during maintenance window should be a manual rsync with the --delete option:\n"
printf "\n\trsync -a --delete --inplace -Ph $SRCDIR1/ $DESTDIR1/\n"
printf "\trsync -a --delete --inplace -Ph $SRCDIR2/ $DESTDIR2/\n"
printf "\trsync -a --delete --inplace -Ph $SRCDIR3/ $DESTDIR3/\n"
printf "\trsync -a --delete --inplace -Ph $SRCDIR4/ $DESTDIR4/\n"
printf "\trsync -a --delete --inplace -Ph $SRCDIR5/ $DESTDIR5/\n"
printf "\trsync -a --delete --inplace -Ph $SRCDIR6/ $DESTDIR6/\n"
printf "\trsync -a --delete --inplace -Ph $SRCDIR7/ $DESTDIR7/\n"

# IF YOU WANT TO LIMIT THE IO PRIORITY, 
# PREPEND THE FOLLOWING TO THE rsync & cd/find COMMANDS ABOVE:
#   ionice -c2
