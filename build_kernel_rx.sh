#!/bin/sh
# Shell script:
#
#       This Shell script will compiler kernel source, generate compiler log and SHA1 code
#       SOURCE_DIR=/home/daily/work/imx51-kernel/trunk/git-imx-android-r2
#	Usage: ./build_kernel.sh
#       
# History:
# 2009/07/27	Jim Lin,	First release
# 2009/07/29    Jim Lin,	Automatic build source code and commit to repo with a tag name 
# 2009/08/04    Jim Lin,	Generate commit log message from git repoistory
GIT_REPO_DIR=/home/daily/softbank/imx-android
REPO_DIR=$PWD
ENV_DIR=/home/daily/work
SHA1_CODE=SHA1_CODE
SOURCE_DIR=/home/daily/work/imx51-kernel/trunk/git-imx-android-r2
KERNEL_IMG_DIR=$SOURCE_DIR/arch/arm/boot
KERNEL_LOG=kernel_build.log
KERNEL_FILE=zImage
RELEASE_LOG_FILE=RELEASE.log
LOG_MESSAGE="Kernel commmit"
NO_AUTO=0
YesNo=No

showhelp() {
bn=`basename $0` 
ver=`echo '$Revision: 1.0 $' | sed 's/.Revision. \(.*\)./\1/'`
cat << eot
====================  $bn Version: $ver ==================

usage $bn [-h] [-t <tag name>] [-m <commit message>] [-n] 

  -h                        displays this help message
  -t <tag name>             the tag name for this commit 
  -m < commmit message>     the message which commit into repo
  -n                        DO NOT commit and make a tag automatically


eot
exit 1
}
on_master_branch()
{
	echo "make repo on master branch & clean"
	git checkout master
	git reset --hard
	git clean -fxd
}
#--------------------- parse command line arguments ----------------------
##
##

if [ $# -lt 1 ]; then
	showhelp
fi

while getopts ht:m:n opt
do
	case $opt in
		h) showhelp ; exit 0
			;;
		t) TAG_NAME=$OPTARG
			;;
		m) LOG_MESSAGE=$OPTARG
			;;
		n) NO_AUTO=1
			;; 
		\?) showhelp
			;;
	esac
done
# if no auto commit, tag name is necessity
if [ -z "$TAG_NAME" -a $NO_AUTO -eq 0 ]; then
	echo "\n"
	echo "NOTE!!! Please specific a tag name with -t option!!!\n"
	exit 1
fi 

echo "tag name    = $TAG_NAME"
echo "log message = $LOG_MESSAGE"

[ $NO_AUTO -eq 0 ] && YesNo=Yes
echo "auto commit = $YesNo" 

#repository sync 
echo "git svn rebase ..."
cd $GIT_REPO_DIR
git svn rebase

echo "Enter $SOURCE_DIR ..."
cd $SOURCE_DIR
git clean -fxd
if [ $? -ne 0 ]; then
	echo "git clean Error"
	exit 1
fi

git reset --hard
if [ $? -ne 0 ]; then
	echo "git reset Error"
	exit 1
fi

echo "Get the latest source code"
git fetch origin
git rebase origin
if [ $? -ne 0 ]; then
	echo "Get the latest source code Error"
	exit 1
fi
echo "Fetching commit messages"
#fetch the first version to the latest version commit messages
git log --pretty=format:'%h : %s' --date-order --graph init..master > $RELEASE_LOG_FILE
echo "make kernel ..."
make clean;nice make -j 4| tee $KERNEL_LOG
echo "copy $KERNEL_IMG_DIR/$KERNEL_FILE to $REPO_DIR ..."
git rev-parse --verify --short HEAD > $SHA1_CODE
cd $REPO_DIR
# make repo clean & on master branch
on_master_branch
cp $KERNEL_IMG_DIR/$KERNEL_FILE $REPO_DIR
echo "move $SOURCE_DIR/$KERNEL_LOG to $REPO_DIR ..."
mv $SOURCE_DIR/$KERNEL_LOG $REPO_DIR
cp $SOURCE_DIR/$SHA1_CODE $REPO_DIR
mv $SOURCE_DIR/$RELEASE_LOG_FILE $REPO_DIR
#chmod 777 $SHA1_CODE $KERNEL_FILE $KERNEL_LOG
# Need to commit to repository?
if [ $NO_AUTO -eq 0 ]; then
	
	git commit -a -m "$LOG_MESSAGE, SHA:`cat $SHA1_CODE`"
	git tag $TAG_NAME
fi
echo "Finished! ..."
exit 0
