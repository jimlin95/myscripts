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
else
	rm $GIT_PROJECT -fr
	git clone ${GIT_PATH}/${GIT_PROJECT}.git
fi

cd $GIT_PROJECT
./doit_3g.sh $PARA
cd -
if [ ! -d $GIT_PROJECT_GMS ]
then	
	git clone ${GIT_PATH}/${GIT_PROJECT_GMS}.git
else
	rm $GIT_PROJECT_GMS -fr
	git clone ${GIT_PATH}/${GIT_PROJECT_GMS}.git
fi
cd $GIT_PROJECT_GMS
cp google $PARA/vendor -a

exit 0
