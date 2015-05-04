#!/bin/sh
echo "Running backup process"
BackupName="Backup_"`date +'%Y_%m_%d_%H_%M_%S'`
BackupFolder="/mnt/Backup"
mkdir $BackupFolder/$BackupName
BackupNameBZ2=$BackupName".tar.bz2"
echo "Compress (1/4)"
cd /mnt/
tar -jcvf $BackupFolder/$BackupName/$BackupNameBZ2 file/codebase fserver/file/
echo "Merge configuration file into it (2/4)"
cp /etc/apache2/sites-available/git.conf $BackupFolder/$BackupName
cp /etc/apache2/passwd $BackupFolder/$BackupName
cp /etc/samba/smb.conf $BackupFolder/$BackupName
cp /etc/bash.bashrc $BackupFolder/$BackupName
cp /etc/gitweb* $BackupFolder/$BackupName
cp /etc/fstab $BackupFolder/$BackupName
cp /etc/exports $BackupFolder/$BackupName
cp /etc/group $BackupFolder/$BackupName
cp /root/ipt.save* $BackupFolder/$BackupName
cp /etc/init.d/iptables.sh $BackupFolder/$BackupName
cp /etc/shadow $BackupFolder/$BackupName
cp /etc/passwd $BackupFolder/$BackupName
cp -rvf /home/git/ $BackupFolder/$BackupName
echo "Copy release image to another HDD for backup (3/4)"
cp -arvf file/ImageRelease fserver/ImageRelease_backup
ls $BackupFolder/$BackupName
echo "Delete oldest backup (4/4)"
rm -rf `ls -al -u | cut -c 46-120 | sed '5,100d' | sed '1,3d'
