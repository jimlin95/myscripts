#!/bin/bash
#
## Program: Flash utility for Android system
#
#
#   Usage: ./flash-images.sh
#
# History:
# 2013/09/17    Jim Lin,    First release
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

CACHE=cache.img
UBOOT=u-boot.bin
RECOVERY=recovery.img
KERNEL=boot.img
SYSTEM=system.img
SDC=sdc.img
USERDATA=userdata.img
XLOADER=MLO

#-----------------------------------------------------------------------------------------------------
# Using commands list
#-----------------------------------------------------------------------------------------------------

MENU_ENTRY()
{
#  echo -e "\x1b[1;36m"
  echo -e "\x1b[1;36mConnect DUT to PC via USB cable"
  echo -e "\x1b[1;36m=========================== Flash Utility =============================\x1b[0m"
  echo -e " 0. Flash All images (with oem format)"
  echo -e " 1. Flash All images"
  echo -e " 2. Flash xloader  image"
  echo -e " 3. Flash u-boot   image"
  echo -e " 4. Flash kernel   image"
  echo -e " 5. Flash system   image"
  echo -e " 6. Flash recovery image"
  echo -e " o. Fastboot \x1b[1;33mO\x1b[0mem format"
  echo -e " r. \x1b[1;33mR\x1b[0meboot DUT (fastboot)"
  echo -e " f. Enter \x1b[1;33mf\x1b[0mastboot mode"
  echo -e " l. \x1b[1;33mL\x1b[0mist usb devices"
  echo -e " q. \x1b[1;33mQ\x1b[0muit"
  echo -e "\x1b[1;36m=======================================================================\x1b[0m"
  echo -e "\x1b[0m \x1b[1;34m"
  read -p "Please enter your choice: " choice
  echo -e "\x1b[0m"
  CHOICE 
}
CHOICE()
{
  case $choice in 
   0)
	echo "Flash All images with oem format "
	adb reboot-bootloader
	fastboot flash bootloader $UBOOT
	fastboot reboot-bootloader
	fastboot oem format
	fastboot flash boot $KERNEL
	fastboot flash system $SYSTEM
	fastboot flash recovery $RECOVERY
	fastboot flash userdata $USERDATA
	fastboot flash cache $CACHE
	fastboot reboot
    ;;
  1)
	echo "Flash All images"
	adb reboot-bootloader
	fastboot flash bootloader $UBOOT
	fastboot flash boot $KERNEL
	fastboot flash system $SYSTEM
	fastboot flash recovery $RECOVERY
	fastboot flash userdata $USERDATA
	fastboot flash cache $CACHE
	fastboot reboot
    ;;
 
  2)
    echo "Flash x-loader(MLO) "
	adb reboot-bootloader
	fastboot flash xloader $XLOADER
	fastboot reboot
    ;;
 
  3)
	echo "Flash u-boot.bin "
	adb reboot-bootloader
	fastboot flash bootloader $UBOOT
	fastboot reboot
    ;;
 
  4)
	echo "Flash boot.img "
	adb reboot-bootloader
	fastboot flash boot $KERNEL
	fastboot reboot
    ;;
 
  5)
	echo "Flash system.img "
	adb reboot-bootloader
	fastboot flash system $SYSTEM  
	fastboot reboot
    ;;
 
  6)
	echo "Flash cache.img "
	adb reboot-bootloader
	fastboot flash cache $CACHE
	fastboot reboot
    ;;
 
  o | O)
  	echo "Oem Format"
	adb reboot-bootloader
	fastboot oem format 
    ;;

  r | R)
	echo "fastboot reboot"
	fastboot reboot 
    ;;

  f | F)
	echo "Enter fastboot mode"
	adb reboot bootloader 
    ;;

  l | L)
	echo "List USB devices "
	lsusb 
    ;;
  
  q | Q)
    echo "Quit."
    exit $EXIT_SUCCESS
    ;;

  *)
    echo "Unknown choice."
    MENU_ENTRY
    ;;
  esac

	if [ $interactive -eq 1 ];then
    MENU_ENTRY
	fi
}

#Main program
if [ $# -eq 0 ]; then
interactive=1
MENU_ENTRY
else
interactive=0
choice=$1
CHOICE
exit $EXIT_SUCCESS
fi
