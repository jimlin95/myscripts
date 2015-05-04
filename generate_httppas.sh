#!/bin/sh
OUTPUT_FILE='account.pd'
OUT_LIST='account.list'

INPUTFILE='member_list.txt'
exec < $INPUTFILE
ID_LIST=""
while read line
do
	PASSWORD=`pwgen -1 -c`
	htpasswd -nbm $line $PASSWORD >> $OUTPUT_FILE
	echo "ID:" $line >> $OUT_LIST	
	echo "PW:" $PASSWORD >>$OUT_LIST 
	echo "------------------------------" >> $OUT_LIST
	ID_LIST=$ID_LIST" "$line
done
echo "GROUP"=$ID_LIST >> $OUT_LIST
exit 0

