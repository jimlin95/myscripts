#!/bin/sh
# Shell script:
#
#       This Shell script will create a directory, and copy tag_redboot, tag_kernel in it.
#       Note: After execute the script , please edit tag_redboot & tag_kernel files to what you want
#	Usage: source ./new_version.sh v0.1
#       
# History:
# 2009/07/27	Jim Lin	First release

CUR_DIR=$PWD
if [ -z "$1" ]; then
	echo Usage: $0 v0.1
	exit 1
fi
mkdir $1
cp -a fetch.sh $1
cp tag_redboot $1
cp tag_kernel  $1

echo "Finished!!!\n"
cd $CUR_DIR/$1
#gedit tag_redboot tag_kernel &
echo NOTE!!!!:Please edit $1/tag_redboot and $1/tag_kernel files,
echo before run fetch.sh script!!!!
exit 0
