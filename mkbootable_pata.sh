#!/bin/bash  
# Program:
#       This program is an unitity for making a bootable PATA Storage
#
#	Usage: ./mkbootable_pata.sh -n /dev/sdc
#       
# History:
# 2009/08/24	Jim Lin,	First release
#-----------------------------------------------------------------------------------------------------
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null

#-----------------------------------------------------------------------------------------------------
# Local definitions
#-----------------------------------------------------------------------------------------------------

MTOOLSRC_FILE="$HOME/.mtoolsrc"
MTOOLS_SKIP_STRING="mtools_skip_check=1"
SYSTEMIMG_SIZE=7   #Reverse 7M bytes for redboot & kernel
ANDROID_SD_SIZE=300  #300M for android sdcard partition
PARTITION2_START=`expr $SYSTEMIMG_SIZE + $ANDROID_SD_SIZE `
ROOTFS_SUPPORT="freescale android millos ubuntu"
ZIMAGE_SOURCE="zImage"
SRC_KERNEL_OFFSET=0
OFFSET_KERNEL=1048576    			# 1M after the start 
ANDROID_SDCARD_FILE="android_sdcard.tar.bz2"
#-----------------------------------------------------------------------------------------------------
# Using commands list
#-----------------------------------------------------------------------------------------------------

SUDO=/usr/bin/sudo
DD=/bin/dd
OD=/usr/bin/od
HEAD=/usr/bin/head
SYNC=/bin/sync
GUNZIP=/bin/gunzip
CMP=/usr/bin/cmp
STAT=/usr/bin/stat
PARTED=/sbin/parted
MKFS_EXT3=/sbin/mkfs.ext3
MKFS_MSDOS=/sbin/mkfs.msdos
MLABEL=/usr/bin/mlabel
TUNE2FS=/sbin/tune2fs
UMOUNT=/bin/umount
MOUNT=/bin/mount
TAR=/bin/tar

if [ ! -e ${SUDO} ] ; then
	echo "Error: ${SUDO} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${DD} ] ; then
	echo "Error: ${DD} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${OD} ] ; then
        echo "Error: ${OD} not found"
        exit $EXIT_FAIL
fi

if [ ! -e ${HEAD} ] ; then
        echo "Error: ${HEAD} not found"
        exit $EXIT_FAIL
fi

if [ ! -e ${SYNC} ] ; then
	echo "Error: ${SYNC} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${GUNZIP} ] ; then
	echo "Error: ${GUNZIP} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${CMP} ] ; then
	echo "Error: ${CMP} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${STAT} ] ; then
	echo "Error: ${STAT} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${PARTED} ] ; then
	echo "Error: ${PARTED} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${MKFS_MSDOS} ] ; then
	echo "Error: ${MKFS_MSDOS} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${MKFS_EXT3} ] ; then
	echo "Error: ${MKFS_EXT3} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${UMOUNT} ] ; then
	echo "Error: ${UMOUNT} not found"
	exit $EXIT_FAIL
fi

######################################################################################################
# functions declare here
######################################################################################################
#-----------------------------------------------------------------------------------------------------
# Help function
#-----------------------------------------------------------------------------------------------------
showhelp() {
bn=`basename $0` 
ver=`echo '$Revision: 1.0 $' | sed 's/.Revision. \(.*\)./\1/'`
cat << eot

====================  $bn Version: $ver ==================

usage $bn [-h] -n <device node name> 

  -h                     displays this help message
  -n <device node>       device node to use.   
    

eot
exit $EXIT_FAIL
}

#-----------------------------------------------------------------------------------------------------
# wait device ready 
#-----------------------------------------------------------------------------------------------------

wait_device_ready()
{		
	#check /dev/sdxx file & ${MOUNT} table
	while  [ ! -e $1$2 ] || [ `${MOUNT} -l | grep $1$2 | wc -l` -ne 0 ] 
	do 
		echo Wait $1$2 ready ...
		${SUDO} ${UMOUNT} $1$2  > ${NULL_DEV} 2>&1
		sleep 0.5
	done
}

######################################################################################################
############### here the script starts
######################################################################################################

#--------------------- parse command line arguments ----------------------
## This loop works only if all switches are preceeded with a "-"
##

while getopts hn: option
do
	case $option in
	    h) showhelp 
			;;
		n) DEVNODE="$OPTARG"
           	echo "DEVNODE=$DEVNODE"
			;;

		\?) showhelp
			;;
	esac
done

if [ -z "$DEVNODE" ]; then
	echo ERROR!! Please input device name!!!
	exit $EXIT_FAIL
fi

#-----------------------------------------------------------------------------------------------------
#check parameters for ${PARTED} & mlabel 
#-----------------------------------------------------------------------------------------------------

if [ ! -f $MTOOLSRC_FILE ]; then
	echo $MTOOLS_SKIP_STRING > $MTOOLSRC_FILE
else
	[ $(grep $MTOOLS_SKIP_STRING $MTOOLSRC_FILE | wc -l) -eq 0 ] && echo $MTOOLS_SKIP_STRING >> $MTOOLSRC_FILE
fi

#-----------------------------------------------------------------------------------------------------
#Get storage size
#-----------------------------------------------------------------------------------------------------

STORAGE_SIZE=`${SUDO} ${PARTED} $DEVNODE print | grep "Disk ${DEVNODE}" |awk '{print $3}' |  sed 's/MB//g'`

#-----------------------------------------------------------------------------------------------------
#find the rootfs file with rootfs-*
#-----------------------------------------------------------------------------------------------------

ROOTFS_FILE_NAME=`find -name "rootfs-*.bz2"`
if [ -z $ROOTFS_FILE_NAME ]; then
    echo "Didn't find any rootfs file with prefix rootfs-"
    exit 
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
		exit $EXIT_FAIL
		;;
	esac


#-----------------------------------------------------------------------------------------------------
#check the rootfs is android???
#-----------------------------------------------------------------------------------------------------

ANDROID_CHECK=`echo $ROOTFS | grep android -c`

#-----------------------------------------------------------------------------------------------------
# when rootfs is selected android, we need two partitions
#-----------------------------------------------------------------------------------------------------

if [ $ANDROID_CHECK -gt 0 ]; then
# make two partitions for android
	${SUDO} ${UMOUNT} $DEVNODE"1" > ${NULL_DEV} 2>&1
	${SUDO} ${UMOUNT} $DEVNODE"2" > ${NULL_DEV} 2>&1
	${SUDO} ${PARTED} -s -- $DEVNODE mklabel msdos
	${SUDO} ${PARTED} -s -- $DEVNODE  mkpart primary fat32 $SYSTEMIMG_SIZE $PARTITION2_START 
    ${SUDO} ${PARTED} -s -- $DEVNODE  mkpart primary ext3 $PARTITION2_START -1 
	${SUDO} ${PARTED} -s -- $DEVNODE set 1 lba off 
	${SYNC}
	wait_device_ready $DEVNODE 1
	echo "Formating ${DEVNODE}1 to FAT32"
	${SUDO} ${MKFS_MSDOS} -I -F 32 $DEVNODE"1" > ${NULL_DEV} 2>&1
	wait_device_ready $DEVNODE 2	
	echo "Formating ${DEVNODE}2 to EXT3"
	${SUDO} ${MKFS_EXT3} -F $DEVNODE"2" > ${NULL_DEV} 2>&1
	echo "Set ${DEVNODE}1 label to $P1_LABEL"
	${SUDO} ${MLABEL} -i $DEVNODE"1" ::$P1_LABEL 
	echo "Set ${DEVNODE}2 label to $P2_LABEL"
	${SUDO} ${TUNE2FS} -L $P2_LABEL $DEVNODE"2" 

else
# make one partition for others
	${SUDO} ${UMOUNT} $DEVNODE"1" > ${NULL_DEV} 2>&1
	${SUDO} ${UMOUNT} $DEVNODE"2" > ${NULL_DEV} 2>&1
	${SUDO} ${PARTED} -s -- $DEVNODE mklabel msdos
	${SUDO} ${PARTED} -s -- $DEVNODE  mkpart primary ext3 $SYSTEMIMG_SIZE -1 
	${SYNC}
	wait_device_ready $DEVNODE 1
	echo "Formating ${DEVNODE}1 to EXT3"
	${SUDO} ${MKFS_EXT3} -F $DEVNODE"1"  > ${NULL_DEV} 2>&1
	echo "Set ${DEVNODE}1 to $P1_LABEL"
	${SUDO} ${TUNE2FS} -L $P1_LABEL $DEVNODE"1" > ${NULL_DEV} 2>&1
	
fi   

#-----------------------------------------------------------------------------------------------------
# Install zImage 
#-----------------------------------------------------------------------------------------------------
#programming

${SUDO} ${DD} if=${ZIMAGE_SOURCE} of=${DEVNODE} bs=${OFFSET_KERNEL} seek=1 > $NULL_DEV  2>&1
ECODE=$?
if [ ${ECODE} -ne 0 ] ; then
	echo "Error: ${DD} failed with exit code ${ECODE}"
	exit $EXIT_FAIL
fi

# verifying

CMP_SIZE=` expr $(stat -c %s ${ZIMAGE_SOURCE}) - ${SRC_KERNEL_OFFSET}`
${SUDO} ${CMP} -n ${CMP_SIZE} -i ${SRC_KERNEL_OFFSET}:${OFFSET_KERNEL} ${ZIMAGE_SOURCE} ${DEVNODE} > $NULL_DEV 2>&1	
	ECODE=$?
	if [ ${ECODE} -ne 0 ] ; then
		echo "Error: ${CMP} failed with exit code ${ECODE}"
		exit $EXIT_FAIL
	fi

#-----------------------------------------------------------------------------------------------------
# Install root file system
#-----------------------------------------------------------------------------------------------------

case $ROOTFS in
	freescale)
    	echo Rootfs is $ROOTFS
		${SUDO} ${MOUNT} $DEVNODE"1" /mnt
		if [ $? -eq 0 ]; then
			${SUDO} tar xjvpf $ROOTFS_FILE_NAME -C /mnt
		else
			echo Error!!! can not ${MOUNT} $DEVNODE"1"
		fi
		${SYNC} 
		${SUDO} ${UMOUNT} $DEVNODE"1" 
		;;		
    android)
		echo Rootfs is $ROOTFS
		${SUDO} ${MOUNT} $DEVNODE"2" /mnt
		if [ $? -eq 0 ]; then
			${SUDO} tar xjvpf $ROOTFS_FILE_NAME -C /mnt
		else
			echo Error!!! can not ${MOUNT} $DEVNODE"1"
		fi
		${SYNC} 
		${SUDO} ${UMOUNT} $DEVNODE"2" 
        ;;
    millos)
		echo Rootfs is $ROOTFS
		${SUDO} ${MOUNT} $DEVNODE"1" /mnt
		if [ $? -eq 0 ]; then
			${SUDO} tar xjvpf $ROOTFS_FILE_NAME -C /mnt
		else
			echo Error!!! can not ${MOUNT} $DEVNODE"1"
		fi
		${SYNC} 
		${SUDO} ${UMOUNT} $DEVNODE"1" 
		;;		

    ubuntu)
		echo Rootfs is $ROOTFS
		${SUDO} ${MOUNT} $DEVNODE"1" /mnt
		if [ $? -eq 0 ]; then
			${SUDO} tar xjvpf $ROOTFS_FILE_NAME -C /mnt
		else
			echo Error!!! can not ${MOUNT} $DEVNODE"1"
		fi
		${SYNC} 
		${SUDO} ${UMOUNT} $DEVNODE"1" 	
		;;				

	*)  echo unknown Rootfs
		echo support rootfs: $ROOTFS_SUPPORT
		exit $EXIT_FAIL
		;;
esac

#-----------------------------------------------------------------------------------------------------
# Install the data for sdcard for android only
#-----------------------------------------------------------------------------------------------------

if [ $ANDROID_CHECK -gt 0 ]; then

	mkdir temp
	${SUDO} ${MOUNT} $DEVNODE"1" /mnt
	if [ $? -eq 0 ]; then
        #FIXME:Why can't extract to /mnt directly
		sudo ${TAR} -xjvf $ANDROID_SDCARD_FILE -C temp
        sudo cp temp/* /mnt
	else
		echo Error!!! can not mount $DEVNODE"1"
	fi
    	rm temp -fr
	${SYNC} 
	sudo ${UMOUNT} $DEVNODE"1" 

fi

exit $EXIT_SUCCESS
