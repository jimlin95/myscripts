#!/bin/sh
# Shell script:
#
#       This Shell script generate patch between two difference directories
#	After completed, please find the patch file in /tmp directory
#	Usage: ./diff_patch.sh linux-2.6.26 linux-2.6.28 patch26to28
#       
# History:
# 2009/07/27	Jim Lin	First release

echo "======diff processing======"
diff -Nur $1 $2 -x ".git" -x ".svn"  > /tmp/$3.patch
exit 0
