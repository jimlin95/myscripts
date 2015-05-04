#!/bin/sh
GIT_PATH=https://10.241.121.21/git/asari-others/
GIT_PROJECT=nec_pre_in
GIT_PROJECT_GMS=gms
SRC_DIR=.
TARGET_DIR=/tmp
PARA=$1

if [ $# -eq 0 ]
then
   echo "$0 \"android_source_top_directory\""
   exit 1
fi

cd $TARGET_DIR
if [ ! -d $GIT_PROJECT ]
then	
	git clone ${GIT_PATH}/${GIT_PROJECT}.git
	cd $GIT_PROJECT
else
	cd $GIT_PROJECT
	git pull
fi

./doit.sh $PARA
cd -
if [ ! -d $GIT_PROJECT_GMS ]
then	
	git clone ${GIT_PATH}/${GIT_PROJECT_GMS}.git
	cd $GIT_PROJECT_GMS
else
	cd $GIT_PROJECT_GMS
	git pull
fi
cp google $PARA/vendor -a

exit 0
