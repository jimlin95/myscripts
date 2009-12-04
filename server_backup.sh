#!/bin/bash  
# Program:
#       This program is an unitity for backup our working server
#
#	Usage: ./server_backup.sh '2009-12-01'
#       
# History:
# 2009/08/24	Jim Lin,	First release
#-----------------------------------------------------------------------------------------------------
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null

#-----------------------------------------------------------------------------------------------------
# Local definitions
#-----------------------------------------------------------------------------------------------------
backup_to="/media/server_backup"
password="123456"

#-----------------------------------------------------------------------------------------------------
rnd=$RANDOM
# $1='2009-12-01'
if [ -n $1 ]; then
	newer="-N $1"
fi
date=`date +%y%m%d`
echo -n "Today is $date. Writing /tmp/$rnd-exclude-file-list ... "

echo "lost+found"                    > /tmp/$rnd-exclude-file-list
echo "/mnt/*"                       >> /tmp/$rnd-exclude-file-list
echo "/media/*"                     >> /tmp/$rnd-exclude-file-list
echo "/proc/*"                      >> /tmp/$rnd-exclude-file-list
echo "/dev/*"                       >> /tmp/$rnd-exclude-file-list
echo "/sys/*"                       >> /tmp/$rnd-exclude-file-list
echo "/tmp/*"                       >> /tmp/$rnd-exclude-file-list
echo "/var/spool/squid/*"           >> /tmp/$rnd-exclude-file-list

echo "done."
echo ""
#-----------------------------------------------------------------------------------------------------

datetime=`date "+%Y-%m-%d %H:%M:%S"`
echo "Backup job started at $datetime"

#-----------------------------------------------------------------------------------------------------
sshfs $backup_from $mount_point
exit 0
echo $password | sudo -S tar -cvpjf $backup_to/$date-full-backup.tar / --totals --absolute-names \
    --ignore-failed-read --exclude-from=/tmp/$rnd-exclude-file-list 
if [ "${?}" != 0 ] ; then
    echo "Backup failed."
fi
rm -f /tmp/$rnd-exclude-file-list
#-----------------------------------------------------------------------------------------------------

datetime=`date "+%Y-%m-%d %H:%M:%S"`
sudo umount $mount_point
echo "Backup job ended at $datetime"
echo ""

