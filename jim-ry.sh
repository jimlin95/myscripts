#! /bin/bash
DATE=`date +%F`
DST="/media/Storage/Jim-rsync/"
LIST="/home/jim/Documents /home/jim/bin /home/jim/script /home/jim/.ssh /home/jim/.gitconfig /home/jim/.netrc /home/jim/.vim"
rsync -avl --delete $LIST $DST 
exit 0


