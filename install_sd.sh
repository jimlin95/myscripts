#!/bin/sh
# Shell script
#
#       This program help to install sd.img or redboot.bin to sd memory card
#	Usage: ./install_sd.sh mount_name
#       Example: ./install_sd.sh android
#
# History:
# 2009/07/27	Jim Lin	First release

SOURCE=sd.img
DEST=/dev/sdc
MEDIA=/media
DISK=$MEDIA/android
if [ -n "$1" ]; then
	DISK=$MEDIA/$1	
fi	
while [ ! -e $DISK ]
do
	echo "wait my device...$DISK"
	sleep 1
done
sleep 1
echo "Unmount devices"
umount /dev/sdd1
umount /dev/sdc2 
umount /dev/sdc1 
echo "Installing data ================>>>> "
sudo dd if=$SOURCE of=$DEST obs=1k seek=1
sync
sudo cmp -i 0:1024 $SOURCE $DEST
echo "finish!"
exit 0
