#!/bin/sh
# Program:
#       This program will make a bootable sd memory card automatically 
#
#	Usage: 
#       
# History:
# 2009/07/28	Jim Lin	First release
SD_IMG=sd.img
SYSTEM_SIZE=`expr 7 \* 1024 \* 1024`   #Reverse 7M bytes for redboot & kernel
ANDROID_SD_SIZE=`expr 300 \* 1024 \* 1024`  #300M for android sdcard partition
ROOTFS="freescale"  # freescale, android, millos
FC_ROOTFS_FILE="fc_rootfs.tar.bz2"
MILLOS_ROOTFS_FILE="millos_rootfs.tar.bz2"
showhelp() {
bn=`basename $0` 
ver=`echo '$Revision: 1.0 $' | sed 's/.Revision. \(.*\)./\1/'`
cat << eot
====================  $bn Version: $ver ==================

usage $bn [-h] [-k <zImage name>] [-r <redboot name>] [-n <device node name>] [-o <offset>]
  -h                     displays this help message
  -k <zImage tag name>   the tag name for fetch kernel image
  -r <redboot tag name>  the tag name for fetch redboot image
  -C DIR                 change to directory DIR

eot
exit 1
}
rootfs_process()
{
	case $ROOTFS in
		freescale)
			echo Rootfs is $ROOTFS
			P1_LABEL="freescale"		#partition 1 label setting
			P2_LABEL=""					#partition 2 label setting
			P1_SIZE="MAX"
			;;		
		  android)
			echo Rootfs is $ROOTFS
			P1_LABEL="sd_card"			#partition 1 label setting
			P2_LABEL="android"			#partition 2 label setting
			P1_SIZE=""
			P2_SIZE="MAX"
			;;		
		   millos)
			echo Rootfs is $ROOTFS
			P1_LABEL="millos"
			P2_LABEL=""
			P1_SIZE="MAX"
			;;		
		   ubuntu)
			echo Rootfs is $ROOTFS
			P1_LABEL="ubuntu"
			P2_LABEL=""
			P1_SIZE="MAX"
			;;		
		
		*)  echo unknown Rootfs
			echo support rootfs: freescale,android,millos,ubuntu
			exit 1
			;;
	esac
}
storage_size_get()
{
	#card size
	CARD_SIZE=`sudo fdisk $DEV_NODE -l | grep "Disk $1" |awk '{print $5}'`
	# cylinders size
	CYN_SIZE=`sudo fdisk $DEV_NODE -l | grep Units |awk '{print $9}'`
	OFFSET=2
	if [ $SYSTEM_SIZE -lt $CYN_SIZE ]; then
		P1_START=2
		echo "START= $P1_START"
	else
		P1_START=`expr $SYSTEM_SIZE / $CYN_SIZE + $OFFSET`
		echo "P1_START=$P1_START"
	fi
	P1_END=`expr $ANDROID_SD_SIZE / $CYN_SIZE + $P1_START + 1`
	P2_START=`expr $P1_END + 1`
	echo "disk size= $CARD_SIZE"
	echo "CYN_SIZE size= $CYN_SIZE"
	echo P1_START=$P1_START
	echo P1_END=$P1_END
	echo P2_START=$P2_START
}
partition1_only()
{

# create one partition only
echo "p
d
1
d
2
n
p
1
$P1_START

p
w
" | sudo fdisk $DEV_NODE

sudo umount $DEV_NODE"1"

sudo mkfs.ext3 $DEV_NODE"1"
sudo tune2fs -L $P1_LABEL $DEV_NODE"1"

}

partition_for_android()
{	

# create one partition only
echo "p
d
1
d
2
n
p
1
$P1_START
$P1_END
n
p
2
$P2_START


p
w
" | sudo fdisk $DEV_NODE

sudo umount $DEV_NODE"1"
sudo umount $DEV_NODE"2"
sudo mkfs.msdos -I -F 32 $DEV_NODE"1"
sudo mkfs.ext3 $DEV_NODE"2"

sudo mlabel -i $DEV_NODE"1" ::$P1_LABEL
sudo tune2fs -L $P2_LABEL $DEV_NODE"2"
}



install_sd_image()
{
	# install sd.img in #DEV_NODE
	if [ ! -e $SD_IMG ]; then 
		echo "ERROR!!Can't find $SD_IMG file"
		exit 1
	fi
	sudo dd if=$SD_IMG of=$DEV_NODE obs=1k seek=1
	sync
	sudo cmp -n $(stat -c %s $SD_IMG) -i 0:1024 $SD_IMG $DEV_NODE

	if [ $? -ne 0 ]; then
		echo $SD_IMG install Fail!!!
		exit 1
	fi
}
install_rootfs()
{
	case $ROOTFS in
		freescale)
			echo Rootfs is $ROOTFS
			sudo mount $DEV_NODE"1" /mnt
			sudo tar xjvf $FC_ROOTFS_FILE -C /mnt
			sync 
			sudo umount $DEV_NODE"1" 
			;;		
		  android)
			echo Rootfs is $ROOTFS
			;;		
		   millos)
			echo Rootfs is $ROOTFS
			sudo mount $DEV_NODE"1" /mnt
			sudo tar xjvf $MILLOS_ROOTFS_FILE -C /mnt
			sync 
			sudo umount $DEV_NODE"1" 
			;;		
		   ubuntu)
			echo Rootfs is $ROOTFS
			;;				
		*)  echo unknown Rootfs
			echo support rootfs: freescale,android,millos,ubuntu
			exit 1
			;;
	esac
}
	
#--------------------- parse command line arguments ----------------------
## This loop works only if all switches are preceeded with a "-"
##

while getopts hn:f:s: option
do
	case $option in
	    h) showhelp 
			;;
		n) DEV_NODE="$OPTARG"
           echo "DEV_CODE=$DEV_NODE"
			;;
	    f) ROOTFS="$OPTARG"
           echo "ROOTFS=$ROOTFS"
			;;
	    s) SD_IMG="$OPTARG"
           echo "SD_IMG=$SD_IMG"
			;;

		\?) showhelp
			;;
	esac
done





if [ -z $DEV_NODE ]; then
	echo ERROR!! Please input device name!!!
	exit 1
fi


rootfs_process
storage_size_get

if [ "$ROOTFS" = "android" ]; then
	partition_for_android
else
	partition1_only	
fi   
# install sd image into $DEV_NODE
install_sd_image
install_rootfs
exit 0
