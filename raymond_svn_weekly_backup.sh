#!/bin/bash
#
# Program:
#       Full and incremental backup script
#
#	Usage: ./raymond_svn_weekly_backup.sh
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
backup_to="/home/jim/mnt/server_backup/svn_raymond"
logfile="$backup_to/log/raymond_svn_weekly_backup.log"
FILE_NAME="svn_weekly_backup.tar"
HOST='10.241.104.242'
USER='quanta'
PASSWD='penguin'

#-----------------------------------------------------------------------------------------------------
datetime=`date "+%Y-%m-%d %H:%M:%S"`

echo -e "\nBackup job started at $datetime" 2>&1 | tee -a $logfile

#-----------------------------------------------------------------------------------------------------
WOY=`date +%U`    # Update full backup date
cd $backup_to
#login Raymond's FTP server
ftp -nv << EOF 2>&1 | tee -a $logfile
open $HOST
user $USER $PASSWD
cd /home/svn
get $FILE_NAME svn_w${WOY}_backup.tar
EOF


datetime=`date "+%Y-%m-%d %H:%M:%S"`
echo "Backup job ended at $datetime"  2>&1 | tee -a $logfile
echo -e "\n-----------------------------------------------------" >> $logfile
exit $EXIT_SUCCESS

