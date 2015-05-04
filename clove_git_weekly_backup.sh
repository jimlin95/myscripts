#!/bin/bash
#
# Program:
#       Full and incremental backup script
#
#	Usage: ./clover_git_weekly_backup.sh
#       
# History:
# 2010/04/14	Jim Lin,	First release
#-----------------------------------------------------------------------------------------------------
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null

#-----------------------------------------------------------------------------------------------------
# Local definitions
#-----------------------------------------------------------------------------------------------------
backup_from="quanta@10.241.121.21:git_backups/git_weekly_backup.7z"
source_from="/home/quanta/git_backups/git_weekly_backup.7z"
#backup_to="/media/server_backup/git_clover"
server_backup=/media/server_backup
backup_to="$server_backup/git_clover"
PATH=/usr/local/bin:/usr/bin:/bin
logfile="$server_backup/git_clover/log/clover_git_weekly_backup.log"
id_file="-i /root/.ssh/id_rsa_clover"
REMOTE="ssh $id_file quanta@10.241.121.21"
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
MD5_SRC=`$REMOTE md5sum $source_from | awk '{print $1}'`
scp $id_file $backup_from $backup_to/git_w${WOY}_backup.7z    
if [ $? -eq 0 ]; then
	echo "scp $id_file $backup_from $backup_to/git_w${WOY}_backup.7z" | tee -a $logfile
else
	echo "Error !!!! scp $backup_from $backup_to/git_w${WOY}_backup.7z" | tee -a $logfile
fi
MD5_DES=`md5sum $backup_to/git_w${WOY}_backup.tar | awk '{print $1}'`
if [ "$MD5_SRC" != "$MD5_DES" ]; then
	echo "$source_from MD5 checksum error" | tee -a $logfile
fi

#-----------------------------------------------------------------------------------------------------
datetime=`date "+%Y-%m-%d %H:%M:%S"`
echo "Backup job ended at $datetime"  2>&1 | tee -a $logfile
echo -e "\n-----------------------------------------------------" >> $logfile
exit $EXIT_SUCCESS

