#!/bin/bash
#--------------------------------------------------------------------------
# Program:
#       This program will move source code in FOLDER_LIST to new place and correct symbolic link in .git
#	for gnu global 
#   Usage:
#       mv4global.sh
#
#  History:
#   2011/12/02    Jim Lin,    First release
#  
#  
CURRENT_DIR=$PWD
CURRENT_DIR_BASE=`basename $PWD`
FOLDER_LIST="x-loader u-boot kernel"
for i in $FOLDER_LIST
do 
	mv $i ../
	ln -s ../$i

	cd ../$i/.git
	#find the broken symbolic links
	TODO=`find -L . -type l | sed -e 's/^\.\///g'`	#remove "./"
	for j in $TODO
	do 
		LN=`readlink $j | sed -e 's/\.\.\/\.\.\///g'` #remove "../../"
		unlink $j
		ln -s ../../${CURRENT_DIR_BASE}/$LN
	done
	cd $CURRENT_DIR
done
exit 0
