#!/bin/bash 
datetime=`date "+%Y%m%d%H%M"`
TMP=/tmp
DST_DIR=dtcp-dev
HEADER_FILES=${TMP}/${DST_DIR}/header_files
LIBRARY_FILES=${TMP}/${DST_DIR}/library_files
TARGET_FILE=dtcp-dev-${datetime}.tar.bz2
HEAD_FILES_LIST="frameworks/base/include frameworks/base/media/libstagefright/include frameworks/base/opengl/include system/core/include hardware/libhardware/include"

#LIBRARY_PATH=./out/target/product/blaze_tablet/obj/SHARED_LIBRARIES
#LIBRARY_FILES_LIST="libstagefright_intermediates/LINKED/libstagefright.so libstagefright_foundation_intermediates/LINKED/libstagefright_foundation.so libmedia_intermediates/LINKED/libmedia.so libbinder_intermediates/LINKED/libbinder.so libutils_intermediates/LINKED/libutils.so libcutils_intermediates/LINKED/libcutils.so liblog_intermediates/LINKED/liblog.so libsurfaceflinger_client_intermediates/LINKED/libsurfaceflinger_client.so"
LIBRARY_PATH=out/target/product/blaze_tablet/system/lib
LIBRARY_FILES_LIST="libstagefright.so libstagefright_foundation.so libmedia.so libbinder.so libutils.so libcutils.so liblog.so libsurfaceflinger_client.so"
rm $TMP/$DST_DIR -fr
mkdir -p $DST_DIR
mkdir -p $HEADER_FILES
mkdir -p $LIBRARY_FILES
cp --parent -r $HEAD_FILES_LIST $HEADER_FILES
pushd $LIBRARY_PATH
cp $LIBRARY_FILES_LIST $LIBRARY_FILES
popd
pushd ${TMP}
tar cjvf $TARGET_FILE $DST_DIR
echo $datetime
