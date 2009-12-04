#!/bin/bash
date=`date +%Y-%m-%d`
tar cvf /home/jim/temp/$date.tar.gz /home/jim/Documents /home/jim/bin ; 
scp -r //home/jim/temp/$date.tar.gz jimlin@Dandelion:backup/jim-desktop/ ; 
find /home/jim/temp/ -name "*.gz" -mtime +1 | xargs rm
exit 0


