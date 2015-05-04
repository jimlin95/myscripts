#!/bin/bash  
# Program:
#       This program is an unitity for making a bootable PATA Storage
#
#       Usage: 
#       
# History:
# 2009/12/04    Jim Lin,        First release
#-----------------------------------------------------------------------------------------------------
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null

#-----------------------------------------------------------------------------------------------------
# Local definitions
#-----------------------------------------------------------------------------------------------------

SVN_REPO=`basename $1`
REV=$2
USER=$3       
PROPNAME=$4
ACTION=$5 
OUTPUT_DIR=/home/quanta/svn_backups
OUTPUT_FILE="${SVN_REPO}-REV-${REV}.dump"
svnadmin dump $SVN_REPO --revision $REV --incremental > $OUTPUT_DIR/$OUTPUT_FILE

exit 0
