#!/bin/sh
# Program:
#       This program will generate Global GTAGs & HTML
#
#   Usage:
#       global_html_generate.sh dirname [main function name]
#
#  History:
#   2011/11/16    Jim Lin,    First release
#  
#  
if [ $# -eq 0 -o $# -gt 2 ]; then
  echo "usage: $0 dirname [main function name]" 1>&2
  exit 1
fi

WORKDIR=`pwd`
SRCDIR=$1

export GTAGSROOT=`pwd`/$SRCDIR

if [ $# -eq 2 ]; then
  MAINFUNC=$2
else
  MAINFUNC=main
fi

cd ${GTAGSROOT}

# you can enable verbose mode with paramters 'v' 
htags -afFnosg  --title ${SRCDIR} --func-header=before --table-flist=1 --main-func ${MAINFUNC} --tabs 8 --statistics 

exit 0
