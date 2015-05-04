#!/bin/bash 
# ----------------------------------------------------------------------------
# Program:
#    This program is an unitity to fetch working log
#
#    Usage:  `basename $0` 
#
#
#  History:
#  2015/01/05    Jim Lin,    First release
# ----------------------------------------------------------------------------

WORKING_LOG_GIT="/mnt/3T/Backup/working-log"
BACKUP_WORKING_LOG_PATH="/home/jim/Backup/working-log"
# Change working path to git path
pushd $BACKUP_WORKING_LOG_PATH
git reset --hard 
git pull 
popd
exit 0
