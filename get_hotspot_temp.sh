#!/bin/bash 
################################################################################################################
#       Author: Jim Lin
#       Purpose: To filer hot spot temp from log
#       Changes:
#               
#               2013-08-23      Initial created  			Jim Lin
#				
#              
#				
#               
#              
#
################################################################################################################

if [ $# -ne 1 ]; then
	echo "$0 filename"
	exit 1
fi

grep "omap_cpu_thermal_manager: hot spot temp" $1 | awk -F " " '{print $7}' - > {$1}-hotspot.log
exit 0
