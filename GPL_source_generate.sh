#!/bin/bash
SRC_DIR=`pwd`
ENTIRE_DIST_DIR=/tmp/Asari-3g-GPL
rm $ENTIRE_DIST_DIR -fr

cd kernel/
git checkout-index --prefix=${ENTIRE_DIST_DIR}/kernel/ -a
cd -

cd external/freetype/
git checkout-index --prefix=${ENTIRE_DIST_DIR}/external/freetype/ -a
cd -

cd external/webkit/
git checkout-index --prefix=${ENTIRE_DIST_DIR}/external/webkit/ -a
cd -

cd external/wpa_supplicant/
git checkout-index --prefix=${ENTIRE_DIST_DIR}/external/wpa_supplicant/ -a
cd -

cd system/bluetooth/
git checkout-index --prefix=${ENTIRE_DIST_DIR}/system/bluetooth/ -a
cd -

cd system/wlan/broadcom
git checkout-index --prefix=${ENTIRE_DIST_DIR}/system/wlan/broadcom/ -a
cd -

cd /tmp
tar czvf Asari-3g-GPL.tar.gz Asari-3g-GPL

rm /tmp/patches -fr
DIST="/tmp/patches"
mkdir ${DIST}/external/freetype -p
mkdir ${DIST}/external/webkit -p
mkdir ${DIST}/external/wpa_supplicant -p
mkdir ${DIST}/kernel -p
mkdir ${DIST}/system/bluetooth -p
mkdir ${DIST}/system/wlan/broadcom -p

cd $SRC_DIR
cd external/freetype/
git diff tegra-10.9.7 > ${DIST}/external/freetype/android_platform_external_freetype.patch
cd -
cd external/webkit/
git diff tegra-10.9.7 > ${DIST}/external/webkit/android_platform_external_webkit.patch
cd -
cd external/wpa_supplicant/
git diff tegra-10.9.7 > ${DIST}/external/wpa_supplicant/android_platform_external_wpa_supplicant.patch
cd -
cd kernel/
git diff tegra-10.9.7 > ${DIST}/kernel/linux-2.6.patch
cd - 
cd system/bluetooth/
git diff tegra-10.9.7 > ${DIST}/system/bluetooth/android_platform_system_bluetooth.patch
cd - 
cd system/wlan/broadcom/
git diff tegra-10.9.7 > ${DIST}/system/wlan/broadcom/android_platform_system_wlan_broadcom.patch
cd - 
#----------------------------------------------------------------------------------
# Gerenate README for patches
BRANCH="froyo-asari-3g"
echo "This directory contains Asari's patches to nVidia's Android release. 

Create an Android tree:	
$ mkdir ~/mydroid 
$ cd ~/mydroid 
$ repo init -u git://nv-tegra.nvidia.com/android/manifest.git -b froyo-tegra
$ repo sync

Switch each repository to the appropriate branch:
$ repo forall -c "git checkout -b $BRANCH tegra-10.9.7"

Apply the patches in each subdirectory." > ${DIST}/README
#----------------------------------------------------------------------------------
cd /tmp
tar czvf LTNA7F_patches.tar.gz patches/


