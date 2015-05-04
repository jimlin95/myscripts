#!/bin/bash
#
# Program:
#       test script menu for MJ3 H/W verifcation
# 
#
#	Usage: ./
#       
# History:
# 2010/03/17	Jim Lin,	First release
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

#-----------------------------------------------------------------------------------------------------
# Using commands list
#-----------------------------------------------------------------------------------------------------

echo "          Contact List"
echo "          ------- ----"
echo "Choose one of the following persons:" 
echo
echo "[E]vans, Roland"
echo "[J]ones, Mildred"
echo "[S]mith, Julie"
echo "[Z]ane, Morris"
echo "[Q]Exit"
echo

while [ 1 ]
do 

        read person

        case "$person" in
        # Note variable is quoted.

          "E" | "e" )
        # Accept upper or lowercase input.
        echo
        echo "        Roland Evans"
        echo "4321 Flash Dr."
        echo "Hardscrabble, CO 80753"
        echo "(303) 734-9874"
        echo "(303) 734-9892 fax"
        echo "revans@zzy.net"
        echo "Business partner & old friend"
        ;;
        # Note double semicolon to terminate each option.

        "J" | "j" )
        echo
        echo "Mildred Jones"
        echo "249 E. 7th St., Apt. 19"
        echo "New York, NY 10009"
        echo "(212) 533-2814"
        echo "(212) 533-9972 fax"
        echo "milliej@loisaida.com"
        echo "Ex-girlfriend"
        echo "Birthday: Feb. 11"
        ;;

        # Add info for Smith & Zane later.
        
        "q" | "Q" )
        echo "Exit"
        exit $EXIT_SUCCESS
        ;;
        
        "12" )
        echo "Exit"
        exit $EXIT_SUCCESS
        ;;

          * )
        # Default option.	  
        # Empty input (hitting RETURN) fits here, too.
        echo
        echo "Not yet in database."
        ;;
        esac
done        

echo


exit $EXIT_SUCCESS


