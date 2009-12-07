#!/bin/bash
#
# Program:
#       Full and incremental backup script
# Based on a script by Gerhard Mourani <gmourani@videotron.ca>
#
#	Usage: ./dandelion_month.sh
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
rnd=$RANDOM
date=`date +%y%m%d`
backup_to="/home/jimlin/Dandelion_Backups"
logfile="/home/jimlin/Dandelion_Backups/log/backup_log"
su_password="jimlin"
COMPUTER="Dandelion"
TIMEDIR="/home/jimlin/Dandelion_Backups/last-full"
PATH=/usr/local/bin:/usr/bin:/bin
OUTPUT="| tee -a $logfile"
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
DOW=`date +%a`              		# Day of the week e.g. Mon
DOM=`date +%d`              		# Date of the Month e.g. 27
DM=`date +%d%b`             	    # Date and Month e.g. 27Sep

echo -n "Today is $date. Writing /tmp/$rnd-exclude-file-list ... " 

echo "lost+found"                    > /tmp/$rnd-exclude-file-list
echo "/home/*"                      >> /tmp/$rnd-exclude-file-list
echo "/mnt/*"                       >> /tmp/$rnd-exclude-file-list
echo "/media/*"                     >> /tmp/$rnd-exclude-file-list
echo "/proc/*"                      >> /tmp/$rnd-exclude-file-list
echo "/dev/*"                       >> /tmp/$rnd-exclude-file-list
echo "/sys/*"                       >> /tmp/$rnd-exclude-file-list
echo "/tmp/*"                       >> /tmp/$rnd-exclude-file-list
echo "/var/spool/squid/*"           >> /tmp/$rnd-exclude-file-list

echo "done."
echo ""
#----------------------------------------------------

datetime=`date "+%Y-%m-%d %H:%M:%S"`

echo -e "\nBackup job started at $datetime" 2>&1 | tee -a $logfile

#-----------------------------------------------------------------------------------------------------
#monthly backup
NEWER=""
FILE_NAME=$COMPUTER-$date-full-backup
echo $su_password | $SUDO -S $TAR -cpf $backup_to/${FILE_NAME}.tar / --totals --absolute-names \
    --ignore-failed-read --exclude-from=/tmp/$rnd-exclude-file-list  2>&1 | tee -a $logfile
if [ "${?}" != 0 ] ; then
    echo "Backup failed." 2>&1 | tee -a $logfile
fi

echo $su_password | $SUDO -S $GZIP -f --best --rsyncable $backup_to/$FILE_NAME.tar 2>&1 | tee -a $logfile
if [ "${?}" != 0 ] ; then
    echo "Gzip failed." 2>&1 | tee -a $logfile
fi

echo $su_password | $SUDO -S $GZIP --test $backup_to/$FILE_NAME.tar.gz 2>&1 | tee -a $logfile
if [ "${?}" != 0 ] ; then
	echo "Check the compressed file integrity failed." 2>&1 | tee -a $logfile
fi
echo $su_password | $SUDO -S chmod a+x $backup_to/$FILE_NAME.tar.gz
ls -alh $backup_to/$FILE_NAME.tar.gz 2>&1 | tee -a $logfile
#-----------------------------------------------------------------------------------------------------
rm -f /tmp/$rnd-exclude-file-list
datetime=`date "+%Y-%m-%d %H:%M:%S"`
echo "Backup job ended at $datetime"  2>&1 | tee -a $logfile
echo -e "\n-----------------------------------------------------" >> $logfile
exit $EXIT_SUCCESS

