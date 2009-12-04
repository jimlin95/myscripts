#!/bin/sh
# Shell script:
#
#       This Shell script will compiler redboot source, generate compiler log and SHA1 code
#       SOURCE_DIR=/home/daily/work/imx51-redboot/trunk/git-redboot-mx51
#	Usage: ./build_redboot.sh
#       
# History:
# 2009/07/27	Jim Lin,	First release
# 2009/07/29    Jim Lin,	Automatic build source code and commit to repo with a tag name 
# 2009/08/04    Jim Lin,	Generate commit log message from git repoistory
REPO_DIR=$PWD
GIT_REPO_DIR=/home/daily/softbank/redboot-mx51
ENV_DIR=/home/daily/work
SHA1_CODE=SHA1_CODE
SOURCE_DIR=/home/daily/work/imx51-redboot/trunk/git-redboot-mx51
REDBOOT_LOG=redboot_build.log
REDBOOT_FILE=redboot.bin
RELEASE_LOG_FILE=RELEASE.log
LOG_MESSAGE="Redboot commmit"
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

#--------------------- parse command line arguments ----------------------
##
##

if [ $# -lt 1 ]; then
	showhelp
fi

while getopts ht:m:n option
do
	case $option in
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
	echo "\nNOTE!!! Please specific a tag name with -t option!!!\n"
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
echo "Enter $ENV_DIR ..."
cd $ENV_DIR
. ./imx-redboot-env
echo "Enter $SOURCE_DIR ..."
cd $SOURCE_DIR
git reset --hard
echo "Get the latest source code, git pull ..."
git fetch origin
git rebase origin
echo "Fetching commit messages"
#fetch the first version to the latest version commit messages
git log --pretty=format:'%h : %s' --date-order --graph init..master > $REPO_DIR/$RELEASE_LOG_FILE
echo "make reboot ..."
make clean;nice make -j 4| tee redboot_build.log
echo "copy reboot.bin to $REPO_DIR ..."
cp install/bin/redboot.bin $REPO_DIR
echo "move $REDBOOT_LOG to $REPO_DIR ..."
mv $REDBOOT_LOG $REPO_DIR
git rev-parse --verify --short HEAD > $SHA1_CODE
cp $SHA1_CODE $REPO_DIR
cd $REPO_DIR
chmod 777 $REDBOOT_FILE $REDBOOT_LOG $SHA1_CODE
# Need to commit to repository?
if [ $NO_AUTO -eq 0 ]; then
	git commit -a -m "$LOG_MESSAGE, SHA:`cat $SHA1_CODE`"
	git tag $TAG_NAME
fi
echo "Finished! ..."
exit 0
