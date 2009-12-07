#!/bin/bash
#
# Program:
#       Full and incremental backup script
#
#	Usage: ./clover_svn_daily_backup.sh
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
PATH=/usr/local/bin:/usr/bin:/bin
server_from="quanta@10.241.121.21"
source_from="/home/quanta/svn_backups"
backup_to="/home/jim/mnt/server_backup/svn_clover"
logfile="/home/jim/mnt/server_backup/svn_clover/log/clover_svn_daily_backup.log"
REMOTE="ssh $server_from"
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
# Daily backup
BACKUP_FILE_LIST=`$REMOTE ls $source_from/*.dump 2> $NULL_DEV`
if [ $? -ne 0 ] ; then
	echo "ERROR!!!! No backup files found" 2>&1 | tee -a $logfile
	datetime=`date "+%Y-%m-%d %H:%M:%S"`
	echo "Backup job ended at $datetime"  2>&1 | tee -a $logfile
	echo -e "\n-----------------------------------------------------" >> $logfile
	exit $EXIT_SUCCESS
	
fi
for PROCESS_FILE in $BACKUP_FILE_LIST
do
	MD5_SRC=`$REMOTE md5sum $PROCESS_FILE | awk '{print $1}'`
	scp -vq $server_from:$PROCESS_FILE $backup_to/ 2>&1 | tee -a $logfile
	MD5_DES=`md5sum $backup_to/$(basename $PROCESS_FILE) | awk '{print $1}'`
	if [ "$MD5_SRC" == "$MD5_DES" ]; then
		$REMOTE rm $PROCESS_FILE 2>&1 | tee -a $logfile
	else 
		echo "$PROCESS_FILE MD5 checksum error" | tee -a $logfile
	fi
done
#-----------------------------------------------------------------------------------------------------
datetime=`date "+%Y-%m-%d %H:%M:%S"`
echo "Backup job ended at $datetime"  2>&1 | tee -a $logfile
echo -e "\n-----------------------------------------------------" >> $logfile
exit $EXIT_SUCCESS

