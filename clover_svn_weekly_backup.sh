#!/bin/bash
#
# Program:
#       Full and incremental backup script
# Based on a script by Gerhard Mourani <gmourani@videotron.ca>
#
#	Usage: ./clover_svn_weekly_backup.sh
#       
# History:
# 2009/12/07	Jim Lin,	First release
#-----------------------------------------------------------------------------------------------------
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null

#-----------------------------------------------------------------------------------------------------
# Local definitions
#-----------------------------------------------------------------------------------------------------
backup_from="quanta@10.241.121.21:svn_backups/svn_weekly_backup.tar"
backup_to="/home/jim/mnt/server_backup/svn_clover"
PATH=/usr/local/bin:/usr/bin:/bin
logfile="/home/jim/mnt/server_backup/svn_clover/log/clover_svn_weekly_backup.log"

#-----------------------------------------------------------------------------------------------------
# Using commands list
#-----------------------------------------------------------------------------------------------------

TAR=/bin/tar
SUDO=/usr/bin/sudo
GZIP=/bin/gzip

if [ ! -e ${SUDO} ] ; then
	echo "Error: ${SUDO} not found"
	exit $EXIT_FAIL
fi

if [ ! -e ${TAR} ] ; then
	echo "Error: ${TAR} not found"
	exit $EXIT_FAIL
fi
if [ ! -e ${GZIP} ] ; then
	echo "Error: ${GZIP} not found"
	exit $EXIT_FAIL
fi

#-----------------------------------------------------------------------------------------------------

datetime=`date "+%Y-%m-%d %H:%M:%S"`
echo -e "\nBackup job started at $datetime" 2>&1 | tee -a $logfile

#-----------------------------------------------------------------------------------------------------
# Weekly full backup always keep it on server
WOY=`date +%U`    # Update full backup date
scp $backup_from $backup_to/svn_w${WOY}_backup.tar    
echo "scp $backup_from $backup_to/svn_w${WOY}_backup.tar" | tee -a $logfile
#-----------------------------------------------------------------------------------------------------
datetime=`date "+%Y-%m-%d %H:%M:%S"`
echo "Backup job ended at $datetime"  2>&1 | tee -a $logfile
echo -e "\n-----------------------------------------------------" >> $logfile
exit $EXIT_SUCCESS

