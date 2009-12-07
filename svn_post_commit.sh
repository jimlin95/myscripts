#!/bin/bash  
# Program:
#       This program is an unitity for making a bootable PATA Storage
#
#	Usage: 
#       
# History:
# 2009/12/04	Jim Lin,	First release
#-----------------------------------------------------------------------------------------------------
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null

#-----------------------------------------------------------------------------------------------------
# Local definitions
#-----------------------------------------------------------------------------------------------------
REPO=/home/svn/tsunami
DST_DIR=/home/quanta/svn_backups
# $1 --> repo 
# $2 revsion
svnadmin dump  $REPO --incremental -r $2> $DST_DIR/$1revision-$2-.dump
