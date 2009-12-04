#!/bin/bash  
# Program:
#       This program is an unitity for patch android source code 
#
#	Usage: 
#	extract package-nvap_android_kernel-firefly2-xxxxxxxx.tar.gz to ~/tegra
#   extract package-nvap_android_shim-firefly2-xxxxxxx.tar.gz to ~/tegra
#   $ cd nvdount
#	$ ./patch_tegra.sh
#   
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
TEGRA_SOURCE=$HOME/tegra
PATTERN_TEGRA_SOURCE="$HOME\/tegra"
PATTERN_FILE_NAME=README
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
GIT=git
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


cleanup()
{
    README_FILES=`find $TEGRA_SOURCE -name "README"`
    OLD_DIR=$PWD
    for FILE_FEED in $README_FILES
    do
       cd $OLD_DIR
       PROCESS_PATH=`echo $FILE_FEED | sed -e 's/\/home\/jim\/tegra\///' -e 's/\/README//'`   
       cd $PROCESS_PATH        
       $GIT reset --hard
       $GIT clean -xfd    
    done
}
#--------------------- parse command line arguments ----------------------
## This loop works only if all switches are preceeded with a "-"
##

while getopts hc option
do
	case $option in
	    h) showhelp 
			;;
		c) echo "reset and clean up ..."
            cleanup     
            exit $EXIT_SUCCESS
			;;

		\?) showhelp
			;;
	esac
done
######################################################################################################
############### here the script starts
######################################################################################################
README_FILES=`find ${TEGRA_SOURCE} -name "$PATTERN_FILE_NAME"`
OLD_DIR=$PWD
for FILE_FEED in $README_FILES
do
    cd $OLD_DIR
    PROCESS_PATH=`echo $FILE_FEED | sed -e 's/'${PATTERN_TEGRA_SOURCE}'\///' -e 's/\/'${PATTERN_FILE_NAME}'//'`
    echo $PROCESS_PATH
    COMMIT_ID=`cat $FILE_FEED | grep commit | sed -e 's/commit//' -e 's/\ \ .*$//g' -e '/^$/d' | head -n 1`
    cd $PROCESS_PATH
    
    $GIT reset --hard $COMMIT_ID # > $NULL_DEV 2>&1
	#echo "$GIT reset --hard $COMMIT_ID"
    $GIT clean -xfd # > $NULL_DEV 2>&1
	#echo "$GIT clean -xfd"
    $GIT apply ~/tegra/$PROCESS_PATH/*tegr* # >  $NULL_DEV 2>&1
	#echo "$GIT apply ~/tegra/$PROCESS_PATH/*tegr*"
    if [ $? -ne 0 ] ; then
        echo "ERROR!!!! in $PROCESS_PATH"
        echo "commit id=$COMMIT_ID"
    fi
done

#install tegra hardware platform code into android
mkdir -p ${OLD_DIR}/hardware/vendor/nvidia
cd ${OLD_DIR}/hardware/vendor/nvidia
cp -rf ${TEGRA_SOURCE}/hardware/vendor/nvidia/tegra/ .


exit $EXIT_SUCCESS
