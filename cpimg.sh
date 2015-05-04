#!/bin/bash 
DST_DIR=/media/mmc/uz1
if [ -n "$1" ] ; then
	DST_DIR=$1
	echo $DST_DIR
fi
cp -v emmc_appsboot.mbn $DST_DIR
cp -v boot.img $DST_DIR
cp -v system.img $DST_DIR
cp -v userdata.img $DST_DIR
cp -v persist.img $DST_DIR
cp -v cache.img $DST_DIR
cp -v recovery.img $DST_DIR

cp -v 8626_msimage.mbn $DST_DIR 
cp -v MPRG8626.mbn $DST_DIR
cp -v rpm.mbn $DST_DIR
cp -v sbl1.mbn $DST_DIR
cp -v sdi.mbn $DST_DIR
cp -v tz.mbn $DST_DIR
cp -v NON-HLOS-APQ.bin $DST_DIR
cp -v gpt_main0.bin $DST_DIR
cp -v gpt_backup0.bin $DST_DIR
sync;sync;sync;
exit 0
 
