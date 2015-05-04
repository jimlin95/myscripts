#!/bin/bash

INPUT_TARGET_PACK=./out/target/product/blaze_tablet/obj/PACKAGING/target_files_intermediates/blaze_tablet-target_files-eng.jim.zip
OUTPUT_SIGNED_OTA="./out/signed-shipping-ota-update.zip"
OUTPUT_SIGNED_IMAGE="./out/signed-shipping-image.zip"
SIGNED_TARGET_PACK="/tmp/qci.zip"
KEY_PATH=scripts/release-keys

if [ $# -gt 0 ]; then
	INPUT_TARGET_PACK="${1}"
fi
if [ $# -gt 1 ]; then
	OUTPUT_SIGNED_OTA="${2}"
fi
if [ $# -gt 2 ]; then
	OUTPUT_SIGNED_IMAGE="${3}"
fi

if [ $# -gt 3 ]; then
	KEY_PATH="${4}"
fi


echo "******************************************************************"
echo "\$1: input file name(absolut path)."
echo "     Default filename: ${INPUT_TARGET_PACK}"
echo "\$2 : output file name(absolut path)."
echo "      Default filename: ${OUTPUT_SIGNED_OTA}"
echo "\$3 : output signed image(absolut or relative path)."
echo "      Default filename: ${OUTPUT_SIGNED_IMAGE}"
echo "\$4 : release key path (absolut or relative path)."
echo "      Default filename: ${KEY_PATH}"
echo " You should call this in the source root folder"
echo "******************************************************************"

# sanity check
if [ ! -f "${INPUT_TARGET_PACK}" ]; then
	echo "${INPUT_TARGET_PACK} does NOT exist!"
	exit 1
fi

# clean up
if [ -f "${SIGNED_TARGET_PACK}" ]; then
	rm -f ${SIGNED_TARGET_PACK}
fi
if [ -f "${OUTPUT_SIGNED_OTA}" ]; then
	rm -f ${OUTPUT_SIGNED_OTA}
fi

echo "******************************************"
echo "*** 1. sign target APKs with our key   ***"
echo "******************************************"
./build/tools/releasetools/sign_target_files_apks -o -d ${KEY_PATH} -e GpsTestApp_loc.apk,Andando.apk,GPSFTAppAdv.apk=${KEY_PATH}/releasekey	-o "${INPUT_TARGET_PACK}" "${SIGNED_TARGET_PACK}"
if [ ! -f "${SIGNED_TARGET_PACK}" ]; then
	echo "!!! Failed: ./build/tools/releasetools/sign_target_files_apks -d ${KEY_PATH} -o ${INPUT_TARGET_PACK} ${SIGNED_TARGET_PACK} !!!"
	exit 1
fi

echo "******************************************"
echo "*** 2. ota_from_target_files...        ***"
echo "******************************************"
./build/tools/releasetools/ota_from_target_files -v -k ${KEY_PATH}/releasekey "${SIGNED_TARGET_PACK}" "${OUTPUT_SIGNED_OTA}"
if [ ! -f "${OUTPUT_SIGNED_OTA}" ]; then
	echo "!!! Failed: ./build/tools/releasetools/ota_from_target_files -v -k ${KEY_PATH}/releasekey ${SIGNED_TARGET_PACK} ${OUTPUT_SIGNED_OTA} !!!"
	exit 1
fi

echo "******************************************"
echo "*** 3. img_from_target_files ...       ***"
echo "******************************************"
./build/tools/releasetools/img_from_target_files "${SIGNED_TARGET_PACK}" "${OUTPUT_SIGNED_IMAGE}"
if [ ! -f "${OUTPUT_SIGNED_IMAGE}" ]; then
	echo "!!! Failed: ../build/tools/releasetools/img_from_target_files ${SIGNED_TARGET_PACK} ${OUTPUT_SIGNED_IMAGE} !!!"
	exit 1
fi

echo "****************************************************************"
echo "***            OK [Output Packages ]                         ***"
echo "*** Signed OTA Package: ${OUTPUT_SIGNED_OTA} ***"
echo "*** Signed Image Pack: ${OUTPUT_SIGNED_IMAGE}        ***"
echo "****************************************************************"
exit 0

