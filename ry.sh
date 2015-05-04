#! /bin/bash
DATE=`date +%F`
SRV="Dandelion"
LIST="/home/jim/Documents /home/jim/bin /home/jim/script /home/jim/Linux "
rsync -avl --delete $LIST -e ssh jimlin@Dandelion:backup/jim-desktop
exit 0


