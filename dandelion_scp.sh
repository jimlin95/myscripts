#!/bin/bash  
# Program:
#       This program is an unitity for backup our working server
#
#	Usage: ./dandelion_scp.sh '2009-12-01'
#       
# History:
# 2009/12/02	Jim Lin,	First release
#-----------------------------------------------------------------------------------------------------
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null

#-----------------------------------------------------------------------------------------------------
# Local definitions
#-----------------------------------------------------------------------------------------------------
backup_to="/home/jim/mnt/server_backup/Dandelion_Backups"
source_from="/home/jimlin/Dandelion_Backups"
password="123456"
logfile="$backup_to/log/sync.log"
REMOTE="ssh jimlin@Dandelion"
#-----------------------------------------------------------------------------------------------------

datetime=`date "+%Y-%m-%d %H:%M:%S"`
echo -e "\nBackup job started at $datetime" | tee -a $logfile
BACKUP_FILE_LIST=`$REMOTE ls $source_from/*.gz 2> $NULL_DEV`
if [ $? -ne 0 ] ; then
	echo "ERROR!!!! No backup files found" 2>&1 | tee -a $logfile
fi

for PROCESS_FILE in $BACKUP_FILE_LIST
do
	MD5_SRC=`$REMOTE md5sum $PROCESS_FILE | awk '{print $1}'`
	scp jimlin@Dandelion:$PROCESS_FILE $backup_to 
	echo "scp $PROCESS_FILE to $backup_to " | tee -a $logfile
	MD5_DES=`md5sum $backup_to/$(basename $PROCESS_FILE) | awk '{print $1}'`
	if [ "$MD5_SRC" == "$MD5_DES" ]; then
		$REMOTE rm $PROCESS_FILE 2>&1 | tee -a $logfile
	else 
		echo "$PROCESS_FILE MD5 checksum error" | tee -a $logfile
	fi
done
datetime=`date "+%Y-%m-%d %H:%M:%S"`
echo "Backup job finished at $datetime" | tee -a $logfile
echo -e "-------------------------------------------------" >> $logfile

exit $EXIT_SUCCESS
#-----------------------------------------------------------------------------------------------------
