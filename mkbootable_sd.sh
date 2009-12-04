#!/bin/sh
# Program:
#       This program will make a bootable sd memory card automatically 
#
#	Usage: 
#       
# History:
# 2009/07/28	Jim Lin,	First release
# 2009/07/31	Jim Lin,	use Parted command instead of fdisk 
SD_IMG=sd.img
SYSTEMIMG_SIZE=7   #Reverse 7M bytes for redboot & kernel
ANDROID_SD_SIZE=300  #300M for android sdcard partition
PARTITION2_START=`expr $SYSTEMIMG_SIZE + $ANDROID_SD_SIZE `
ROOTFS="freescale"  # freescale, androidr2, androidr3, millos
ANDROID_SDCARD_FILE="android_sdcard.tar.bz2"
MTOOLSRC_FILE="$HOME/.mtoolsrc"
MTOOLS_SKIP_STRING="mtools_skip_check=1"
ROOTFS_SUPPORT="freescale android millos ubuntu"
showhelp() {
bn=`basename $0` 
ver=`echo '$Revision: 1.0 $' | sed 's/.Revision. \(.*\)./\1/'`
cat << eot
====================  $bn Version: $ver ==================

usage $bn [-h] -n <device node name>  [-f <rootfs type>] [-s <sd image filename> ]
  -h                     displays this help message
  -n <device node>       device node to use. 
  -s <sd image name>     new sd image filename,Default is SD_IMG=${SD_IMG}

eot
exit 1
}
pause()
{
	read -p "PAUSE!!!press any key to contiune!!" dummy
}
#for parted & mlabel used
check_mtool_config_file()
{

	if [ ! -f $MTOOLSRC_FILE ]; then
		echo $MTOOLS_SKIP_STRING > $MTOOLSRC_FILE
	else
		[ $(grep $MTOOLS_SKIP_STRING $MTOOLSRC_FILE | wc -l) -eq 0 ] && echo $MTOOLS_SKIP_STRING >> $MTOOLSRC_FILE
	fi
	
}
rootfs_process()
{
#find the rootfs file with rootfs-*
    ROOTFS_FILE_NAME=`find -name "rootfs-*.bz2"`
    if [ -z $ROOTFS_FILE_NAME ]; then
        echo "Didn\'t find any rootfs file with prefix rootfs-"
        exit 1
    fi
    for ROOTFS_CHECK in $ROOTFS_SUPPORT
    do 
        ISFOUND=`echo $ROOTFS_FILE_NAME | grep $ROOTFS_CHECK -c`
        if [ $ISFOUND -gt 0 ]; then
            ROOTFS=$ROOTFS_CHECK            
            break;
        fi
    done
    echo "rootfs filename == $ROOTFS_FILE_NAME"
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
	CARD_SIZE=`sudo parted $DEV_NODE print | grep "Disk $DEV_NODE" |awk '{print $3}' |  sed 's/MB//g'`	
}
wait_device_ready()
{		
	#check /dev/sdxx file & mount table
	while  [ ! -e $1$2 ] || [ `mount -l | grep $1$2 | wc -l` -ne 0 ] 
	do 
		echo Wait $1$2 ready ...
		sudo umount $1$2  > /dev/null 2>&1
		sleep 0.5
	done
}

partition1_only()
{
	sudo umount $DEV_NODE"1" > /dev/null 2>&1
	sudo umount $DEV_NODE"2" > /dev/null 2>&1
	sudo parted -s -- $DEV_NODE mklabel msdos
	sudo parted -s -- $DEV_NODE  mkpart primary ext3 $SYSTEMIMG_SIZE -1 
	sync
	wait_device_ready $DEV_NODE 1
	echo "Formating ${DEV_NODE}1 to EXT3"
	sudo mkfs.ext3 -F $DEV_NODE"1"  > /dev/null 2>&1
	echo "Set ${DEV_NODE}1 to $P1_LABEL"
	sudo tune2fs -L $P1_LABEL $DEV_NODE"1" > /dev/null 2>&1
}

partition_for_android()
{	
	sudo umount $DEV_NODE"1" > /dev/null 2>&1
	sudo umount $DEV_NODE"2" > /dev/null 2>&1
	sudo parted -s -- $DEV_NODE mklabel msdos
	sudo parted -s -- $DEV_NODE  mkpart primary fat32 $SYSTEMIMG_SIZE $PARTITION2_START 
    sudo parted -s -- $DEV_NODE  mkpart primary ext3 $PARTITION2_START -1 
	sudo parted -s -- $DEV_NODE set 1 lba off 
	sync
	wait_device_ready $DEV_NODE 1
	echo "Formating ${DEV_NODE}1 to FAT32"
	sudo mkfs.msdos -I -F 32 $DEV_NODE"1" > /dev/null 2>&1
	wait_device_ready $DEV_NODE 2	
	echo "Formating ${DEV_NODE}2 to EXT3"
	sudo mkfs.ext3 -F $DEV_NODE"2" > /dev/null 2>&1
	echo "Set ${DEV_NODE}1 label to $P1_LABEL"
	sudo mlabel -i $DEV_NODE"1" ::$P1_LABEL 
	echo "Set ${DEV_NODE}2 label to $P2_LABEL"
	sudo tune2fs -L $P2_LABEL $DEV_NODE"2" 
}



install_sd_image()
{
	# install sd.img in #DEV_NODE
	if [ ! -e $SD_IMG ]; then 
		echo "ERROR!!Can't find $SD_IMG file"
		exit 1
	fi
	echo "Installing $SD_IMG to $DEV_NODE"
	sudo dd if=$SD_IMG of=$DEV_NODE obs=1k seek=1 > /dev/null 2>&1
	sync
	sudo cmp -n $(stat -c %s $SD_IMG) -i 0:1024 $SD_IMG $DEV_NODE >/dev/null 2>&1

	if [ $? -ne 0 ]; then
		echo $SD_IMG install Fail!!!
		exit 1
	fi
	echo "Verify image ...PASS"
}
install_rootfs()
{
	case $ROOTFS in
		freescale)
			echo Rootfs is $ROOTFS
			sudo mount $DEV_NODE"1" /mnt

			if [ $? -eq 0 ]; then
				sudo tar xjvpf $ROOTFS_FILE_NAME -C /mnt
			else
				echo Error!!! can not mount $DEV_NODE"1"
			fi
			sync 
			sudo umount $DEV_NODE"1" 
			;;		
		  android)
			echo Rootfs is $ROOTFS
			sudo mount $DEV_NODE"2" /mnt
			if [ $? -eq 0 ]; then
				sudo tar xjvpf $ROOTFS_FILE_NAME -C /mnt
			else
				echo Error!!! can not mount $DEV_NODE"1"
			fi
			sync 
			sudo umount $DEV_NODE"2" 
            ;;

		   millos)
			echo Rootfs is $ROOTFS
			sudo mount $DEV_NODE"1" /mnt
			if [ $? -eq 0 ]; then
				sudo tar xjvpf $ROOTFS_FILE_NAME -C /mnt
			else
				echo Error!!! can not mount $DEV_NODE"1"
			fi
			sync 
			sudo umount $DEV_NODE"1" 
			;;		

		   ubuntu)
			echo Rootfs is $ROOTFS
			sudo mount $DEV_NODE"1" /mnt

			if [ $? -eq 0 ]; then
				sudo tar xjvpf $ROOTFS_FILE_NAME -C /mnt
			else
				echo Error!!! can not mount $DEV_NODE"1"
			fi
			sync 
			sudo umount $DEV_NODE"1" 	
			;;				

		*)  echo unknown Rootfs
			echo support rootfs: $ROOTFS_SUPPORT
			echo 
			exit 1
			;;
	esac
}
install_sdcard_data()
{
	mkdir temp
	
	sudo mount $DEV_NODE"1" /mnt
	if [ $? -eq 0 ]; then
		sudo tar xjvpf $ANDROID_SDCARD_FILE -C temp
	else
		echo Error!!! can not mount $DEV_NODE"1"
	fi
	sudo cp temp/* /mnt
	sudo rm temp -r
	sync 
	sudo umount $DEV_NODE"1" 
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
	    s) SD_IMG="$OPTARG"
           echo "SD_IMG=$SD_IMG"
			;;

		\?) showhelp
			;;
	esac
done





if [ -z "$DEV_NODE" ]; then
	echo ERROR!! Please input device name!!!
	exit 1
fi


check_mtool_config_file
#get storage size
storage_size_get
# select rootfs 
rootfs_process
ANDROID_CHECK=`echo $ROOTFS | grep android -c`

# when rootfs is selected android, we need two partitions
if [ $ANDROID_CHECK -gt 0 ]; then
	partition_for_android
else
	partition1_only	
fi   
# install sd image into $DEV_NODE
install_sd_image
install_rootfs
if [ $ANDROID_CHECK -gt 0 ]; then
	install_sdcard_data
fi
exit 0
