#!/bin/bash  
# Program:
#       This program generates version number for redboot
#
#	Usage: 
#       
# History:
# 2009/08/31	Jim Lin,	First release
#-----------------------------------------------------------------------------------------------------
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null
TARGET=install/include

scm=`./setlocalversion`
echo "#define CYGDAT_REDBOOT_CUSTOM_VERSION" ${scm#-} > ${TARGET}/ver.h
exit $EXIT_SUCCESS
