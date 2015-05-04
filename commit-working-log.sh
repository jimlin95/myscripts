#!/bin/bash 
# ----------------------------------------------------------------------------
# Program:
#    This program is an unitity for backup working log
#
#    Usage:  `basename $0` 
#
#
#  History:
#  2015/01/05    Jim Lin,    First release
# ----------------------------------------------------------------------------

COMMIT_DATE=$(date +"%Y/%m/%d %H:%M:%S")
COMMIT_LOG="Updated on $COMMIT_DATE"
WORKING_LOG_PATH="/home/lcadmin/data-pool/working_log"
WORKING_LOG_GIT="/mnt/3T/working-log"

# Copy files from working_log in samba path to git path.
cp $WORKING_LOG_PATH/* $WORKING_LOG_GIT/ -a

# Change working path to git path
pushd $WORKING_LOG_GIT

DATE_STRING="2006-03-28 00:00:00"
AUTHOR_DATE=$(date -d "$DATE_STRING" "+%s %z")

# Add updated files
git add *

# Commit changes to git 
GIT_AUTHOR_NAME="Jim Lin" \
GIT_AUTHOR_EMAIL="<jim_lin@quantatw.com>" \
GIT_COMMITTER_NAME="Jim Lin" \
GIT_COMMITTER_EMAIL="<jim_lin@quantatw.com>" \
GIT_AUTHOR_DATE="$AUTHOR_DATE" \
git commit -s -m "$COMMIT_LOG"

popd
exit 0
