#!/bin/bash
#
## Program: Flash utility for Android system
#
#
#   Usage: ./uz1_create_out.sh
#
# History:
# 2014/09/02    Sakia Lien, First release
#

Y=`date +%Y`
m=`date +%m`
d=`date +%d`
H=`date +%H`
M=`date +%M`
S=`date +%S`

DATE_STRING=$Y$m$d$H$M$S
#BUILD_TIME=$Y$m$d

PROJECT_NAME=uz1_1339
DAILYBUILD_TYPE=daily  #regular or daily

DAILYBUILD_ROOT=/home/lcadmin/dailybuild
CODE_ROOT=${DAILYBUILD_ROOT}/code
SRC_ROOT=${CODE_ROOT}/${PROJECT_NAME}/${DAILYBUILD_TYPE}/src
ANDROID_ROOT=${SRC_ROOT}/LINUX/android

SAMBA_ROOT=/home/lcadmin/Dailybuild
LOCAL_FOLDER=${SAMBA_ROOT}/${PROJECT_NAME}/${DAILYBUILD_TYPE}/${PROJECT_NAME}_out_${DATE_STRING}
LOCAL_FILE=${PROJECT_NAME}_out.tar.gz

FTP_SERVER_IP=10.242.249.5
FTP_USER_NAME=uz1_imag
FTP_USER_PASSWORD=d8g2s5ds
FTP_FOLDER="./To\ FJ/out_files"


#cd ${ANDROID_ROOT}
#mkdir -p ${LOCAL_ROOT}
#tar -cjvf ${LOCAL_FILE} out

#cd ${LOCAL_FOLDER}

## ftp starts here
ftp -v -in <<EOF
open $FTP_SERVER_IP
user $FTP_USER_NAME $FTP_USER_PASSWORD
cd ${FTP_FOLDER} 
put ${LOCAL_FILE}
close 
bye
EOF

echo $1 to ${FTP_FOLDER} ! 
