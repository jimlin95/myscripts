#!/bin/bash
#--------------------------------------------------------------------------
# Program:
#       This program will move kernel source code to new place and modify symbolic link in .git
#	for gnu global 
#   Usage:
#       mv_kernel.sh new_kernel_directory_name
#
#  History:
#   2011/12/02    Jim Lin,    First release
#  
#  
if [ "$1" == "" ]; then
	echo "Usage:"
	echo "$0 new_kernel_name"
	exit 1
fi
CURRENT_DIR=`basename $PWD`
mv kernel ../$1
ln -s ../$1 kernel
cd ../$1/.git

TODO=`find -L . -type l | sed -e 's/^\.\///g'`
for i in $TODO
do 
	LN=`readlink $i | sed -e 's/\.\.\/\.\.\///g'`
	unlink $i
	ln -s ../../${CURRENT_DIR}/$LN
done

exit 0
