#!/bin/bash
# Shell script:
#
#       
#       Please put it in targetfs directory
#	
#       
# History:
# 
# 2010/05/12    Jim Lin,	Automatic generate the version for root file system
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null
MD5_LIST="md5.list"
DES_DIR="etc"
ROOTFS_VER=rootfs-version
TARGETFS=$1
TARGETFS_FILENAME="targetfs"

MD5SUM=/usr/bin/md5sum
TEE=/usr/bin/tee
if [ ! -e ${MD5SUM} ] ; then
	echo "Error: ${MD5SUM} not found"
	exit $EXIT_FAIL
fi
if [ ! -e ${TEE} ] ; then
	echo "Error: ${TEE} not found"
	exit $EXIT_FAIL
fi


sudo rm ${TARGETFS}/$DES_DIR/$ROOTFS_VER -f
sudo rm ${TARGETFS}/${DES_DIR}/$MD5_LIST -f
sudo find $TARGETFS -type f | xargs sudo $MD5SUM | sudo ${TEE} -a ${TARGETFS}/${DES_DIR}/$MD5_LIST 
VER=`sudo $MD5SUM ${TARGETFS}/${DES_DIR}/$MD5_LIST | awk '{print $1}' | sudo ${TEE} ${TARGETFS}/$DES_DIR/$ROOTFS_VER`
sudo tar cjvf ${TARGETFS_FILENAME}-${VER}.tar.bz2 $TARGETFS 
exit $EXIT_SUCESS


