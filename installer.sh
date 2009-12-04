#!/bin/bash  
# Program:
#       This program is an unitity for updating images, such as redboot ,kernel, rootfs
#
#	Usage: 
#       
# History:
# 2009/08/04	Jim Lin,	First release


# Default Offset values
OFF_KERNEL=1048576    			# 1M after the start 
OFF_REDBOOT=1024				# 1K after the MBR
REDBOOT_SEEK=1
REDBOOT_SRC_OFFSET=1024
KERNEL_SRC_OFFSET=0
REDBOOT_SEEK=1
DEF_DEVNODE="/dev/sdc"			# default applies to target
LOGFILE=installer.log
REDBOOT_SOURCE="install/bin/redboot.bin"
ZIMAGE_SOURCE="arch/arm/boot/zImage"
NULL_DEV=/dev/null

# default actions. None
DO_REDBOOT=0
DO_KERNEL=0
DEVNODE=${DEF_DEVNODE}

# default commands
SUDO=/usr/bin/sudo
DD=/bin/dd
OD=/usr/bin/od
HEAD=/usr/bin/head
SYNC=/bin/sync
GUNZIP=/bin/gunzip
CMP=/usr/bin/cmp
STAT=/usr/bin/stat


if [ ! -e ${SUDO} ] ; then
	echo "Error: ${SUDO} not found"
	exit 1
fi

if [ ! -e ${DD} ] ; then
	echo "Error: ${DD} not found"
	exit 1
fi

if [ ! -e ${OD} ] ; then
        echo "Error: ${OD} not found"
        exit 1
fi

if [ ! -e ${HEAD} ] ; then
        echo "Error: ${HEAD} not found"
        exit 1
fi

if [ ! -e ${SYNC} ] ; then
	echo "Error: ${SYNC} not found"
	exit 1
fi

if [ ! -e ${GUNZIP} ] ; then
	echo "Error: ${GUNZIP} not found"
	exit 1
fi

if [ ! -e ${CMP} ] ; then
	echo "Error: ${CMP} not found"
	exit 1
fi

if [ ! -e ${STAT} ] ; then
	echo "Error: ${STAT} not found"
	exit 1
fi

showhelp() {
bn=`basename $0` 
ver=`echo '$Revision: 1.0 $' | sed 's/.Revision. \(.*\)./\1/'`
cat << eot

====================  $bn Version: $ver ==================

usage $bn [-h] -n <device node name>  [-b] [-r <redboot image>]
                   [-k] [-z <kernel image>]

  -h                     displays this help message
  -n <device node>       device node to use.   
  -b                     do update redboot image 
                         REDBOOT_SOURCE=${REDBOOT_SOURCE}
  -r <redboot image>     do update redboot image, need to specific redboot path
  -k                     do update kernel image 
                         ZIMAGE_SOURCE=${ZIMAGE_SOURCE}
  -z <kernel image>      do update kernel image, need to specific zImage path
    

eot
exit 1
}
update_chunk() {
	local FILE=$1
 	local OFFSET=$3
	local NODE=$2
	# redboot need to skip padding data
	if [ $DO_REDBOOT -eq 1 ]; then
		SKIP="skip=1"
	fi
    # echo "running: ${DD} if=${FILE} of=${NODE} bs=${OFFSET} seek=1"
    ${SUDO} ${DD} if=${FILE} of=${NODE} bs=${OFFSET} seek=1 ${SKIP} > $NULL_DEV  2>&1
	ECODE=$?
	if [ ${ECODE} -ne 0 ] ; then
		echo "Error: ${DD} failed with exit code ${ECODE}"
		exit 1
	fi
}

verify_chunk(){
	local FILE=$1
	local NODE=$2
	local SRC_OFFSET=$3
 	local DES_OFFSET=$4
	local CMP_SIZE=` expr $(stat -c %s ${FILE}) - ${SRC_OFFSET}`
	# echo "running: ${CMP} -n ${CMP_SIZE} -i ${SRC_OFFSET}:${DES_OFFSET} ${FILE}
    ${SUDO} ${CMP} -n ${CMP_SIZE} -i ${SRC_OFFSET}:${DES_OFFSET} ${FILE} ${NODE} > $NULL_DEV 2>&1	
	ECODE=$?
	if [ ${ECODE} -ne 0 ] ; then
		echo "Error: ${CMP} failed with exit code ${ECODE}"
		exit 1
	fi
}
#--------------------- parse command line arguments ----------------------
## This loop works only if all switches are preceeded with a "-"
##

while getopts hn:r:kz:b option
do
	case $option in
	    h) showhelp 
			;;
		n) DEVNODE="$OPTARG"
           	echo "DEVNODE=$DEVNODE"
			;;
		b) DO_REDBOOT=1
			echo "Update Redboot"
			;;
		r) R="$OPTARG"
			REDBOOT_SOURCE=$R
			DO_REDBOOT=1
			echo "Update Redboot"
			;;

		k) 	DO_KERNEL=1
			echo "Update Kernel"
			;;
		z) 	Z="$OPTARG"
			ZIMAGE_SOURCE=$Z
			DO_KERNEL=1
			echo "Update Kernel"
			;;

		\?) showhelp
			;;
	esac
done

############### here the script starts

if [ -z "$DEVNODE" ]; then
	echo ERROR!! Please input device name!!!
	exit 1
fi

if [ $DO_REDBOOT -eq 0 ] && [ $DO_KERNEL -eq 0 ]; then
	echo 'ERROR!! Please make a selection for redboot (-b,-r) or kernel (-k,-z)!!!'
	exit 1
fi

##### Wait disk mounting
while  [ ! -e $DEVNODE ] || [ `mount -l | grep ${DEVNODE}1 | wc -l` -eq 0 ] 
do
	echo "waiting my device...$DEVNODE"
	sleep 1
done
#####



sudo umount $DEVNODE > /dev/null 2>&1 

# do I have to update redboot ?
if [ $DO_REDBOOT -eq 1 ] ; then
	echo "Writing redboot ${REDBOOT_SOURCE} to ${DEVNODE}..."
	if [ ! -e ${REDBOOT_SOURCE} ] ; then
		echo " Failed"
		echo "${REDBOOT_SOURCE}: no such file or directory"
		exit 1
	fi

	#            		FILE           NODE       OFFSET   
	update_chunk ${REDBOOT_SOURCE} ${DEVNODE} ${OFF_REDBOOT} 
	${SYNC}
	#					FILE 		NODE			SRC_OFFSET			DES_OFFSET
	verify_chunk ${REDBOOT_SOURCE} ${DEVNODE} ${REDBOOT_SRC_OFFSET} ${OFF_REDBOOT}

fi

# do I have to update the kernel ?
if [ $DO_KERNEL -eq 1 ] ; then
	echo "Writing the kernel ${ZIMAGE_SOURCE} to ${DEVNODE}..."
	if [ ! -e ${ZIMAGE_SOURCE} ] ; then
		echo " Failed"
		echo "${ZIMAGE}: no such file or directory"
		exit 1
	fi
	#            FILE              NODE       OFFSET   
	update_chunk ${ZIMAGE_SOURCE} ${DEVNODE} ${OFF_KERNEL} 	
	${SYNC}
	#					FILE 		NODE			SRC_OFFSET		DES_OFFSET
	verify_chunk ${ZIMAGE_SOURCE} ${DEVNODE} ${KERNEL_SRC_OFFSET} ${OFF_KERNEL}
fi

# now sync the drives!
${SYNC} ; ${SYNC} ; ${SYNC}
echo "  Done"
exit 0
