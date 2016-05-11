#!/bin/bash
#
## Program: Flash utility for Android system
#
#
#   Usage: ./flash-qualcomm.sh
#
# History:
# 2013/09/17    Jim Lin,    First release
# 2014/07/31    Jim Lin,    Add flash splash.img, IMAGE_PATH can changed by environment.
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
if [ "$IMAGE_PATH" == "" ];then
IMAGE_PATH=.
fi

GPT=${IMAGE_PATH}/gpt_both0.bin

SBL1=${IMAGE_PATH}/sbl1.mbn
SDI=${IMAGE_PATH}/sdi.mbn
RPM=${IMAGE_PATH}/rpm.mbn 
TZ=${IMAGE_PATH}/tz.mbn 
NON_HLOS=${IMAGE_PATH}/NON-HLOS-APQ.bin
PERSIST=${IMAGE_PATH}/persist.img
	
APPBOOT=${IMAGE_PATH}/emmc_appsboot.mbn 
RECOVERY=${IMAGE_PATH}/recovery.img
KERNEL=${IMAGE_PATH}/boot.img
CACHE=${IMAGE_PATH}/cache.img
SYSTEM=${IMAGE_PATH}/system.img
USERDATA=${IMAGE_PATH}/userdata.img
BOOTLOGO=${IMAGE_PATH}/splash.img
LOG=${IMAGE_PATH}/Log.img
KITTING=${IMAGE_PATH}/kitting.img

function pause()
{
  read -p "$*"
}

#-----------------------------------------------------------------------------------------------------
# Using commands list
#-----------------------------------------------------------------------------------------------------

MENU_ENTRY()
{
  echo -e "\x1b[1;36m"
  echo -e "\x1b[1;33mIMAGE_PATH=$IMAGE_PATH\x1b[0m"
  echo -e "\x1b[1;36mConnect DUT to PC via USB cable"
  echo -e "\x1b[1;36m=========================== Flash Utility =============================\x1b[0m"
  echo -e " 0. Flash All images (with erase all)"
  echo -e " 1. Flash All images"
  echo -e " 2. Flash SBL1 image"
  echo -e " 3. Flash lk image"
  echo -e " 4. Flash kernel image"
  echo -e " 5. Flash system image"
  echo -e " 6. Flash recovery image"
  echo -e " 7. Flash userdata image"
  echo -e " 8. Flash cache image"
  echo -e " 9. Flash bootlogo image"
  echo -e " g. Fastboot write \x1b[1;33mg\x1b[0mpt table (erase all)"
  echo -e " r. \x1b[1;33mR\x1b[0meboot DUT (fastboot)"
  echo -e " f. Enter \x1b[1;33mf\x1b[0mastboot mode"
  echo -e " l. \x1b[1;33mL\x1b[0mist usb devices"
  echo -e " k. adb \x1b[1;33mK\x1b[0mill server"
  echo -e " q. \x1b[1;33mQ\x1b[0muit"
  echo -e " b. \x1b[1;33mB\x1b[0mackup persist partition"
  echo -e " p. Restore \x1b[1;33mp\x1b[0mersist partition"
  echo -e " m. Backup \x1b[1;33mm\x1b[0modem  partition"
  echo -e " o. Restore m\x1b[1;33mo\x1b[0mdem partition"
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
	fastboot flash partition $GPT
	fastboot flash modem $NON_HLOS
	fastboot flash sbl1 $SBL1
	fastboot flash sbl1bak $SBL1
	fastboot flash sdi $SDI
	fastboot flash aboot $APPBOOT
	fastboot flash abootbak $APPBOOT
	fastboot flash rpm $RPM
	fastboot flash rpmbak $RPM
	fastboot flash boot $KERNEL
	fastboot flash tz $TZ 
	fastboot flash tzbak $TZ
	fastboot flash system $SYSTEM
	fastboot flash persist $PERSIST
	fastboot flash recovery $RECOVERY
	fastboot flash cache $CACHE
	fastboot flash userdata $USERDATA
	fastboot flash splash $BOOTLOGO
	fastboot flash Log $LOG
	fastboot flash kitting $KITTING
	fastboot reboot
    ;;
  1)
	echo "Flash All images"
	adb reboot-bootloader
	fastboot flash modem $NON_HLOS
	#fastboot flash sbl1 $SBL1
	#fastboot flash sbl1bak $SBL1
	fastboot flash sdi $SDI
	fastboot flash aboot $APPBOOT
	fastboot flash abootbak $APPBOOT
	fastboot flash rpm $RPM
	fastboot flash rpmbak $RPM
	fastboot flash boot $KERNEL
	fastboot flash tz $TZ 
	fastboot flash tzbak $TZ
	fastboot flash system $SYSTEM
	fastboot flash recovery $RECOVERY
	fastboot flash cache $CACHE
	fastboot flash userdata $USERDATA
	fastboot flash splash $BOOTLOGO
	fastboot flash Log $LOG
	fastboot flash kitting $KITTING
	fastboot reboot
	;;
 
  2)
    echo "Flash sbl1.mbn "
	adb reboot-bootloader
    fastboot flash sbl1 $SBL1
	fastboot flash sbl1bak $SBL1
	fastboot reboot
    ;;
 
  3)
	echo "Flash emmc_appsboot.mbn(lk) "
	adb reboot-bootloader
    fastboot flash aboot $APPBOOT
	fastboot flash abootbak $APPBOOT
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
	echo "Flash recovery.img "
	adb reboot-bootloader
	fastboot flash recovery $RECOVERY
	fastboot reboot
    ;;

  7)
	echo "Flash userdata.img "
	adb reboot-bootloader
	fastboot flash userdata $USERDATA
	fastboot reboot
    ;;

  8)
	echo "Flash cache.img "
	adb reboot-bootloader
	fastboot flash cache $CACHE
	fastboot reboot
    ;;

  9)
	echo "Flash splash.img(bootlogo) "
	adb reboot-bootloader
	fastboot flash splash $BOOTLOGO
	fastboot reboot
    ;;

  g | G)
  	echo "write partition"
	adb reboot-bootloader
	fastboot flash partition $GPT  

    ;;

  r | R)
	echo "fastboot reboot"
	pause 'Press any key to continue...'
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

  k | K)
	echo "adb kill-server"
	adb kill-server
    ;;

  q | Q)
    echo "Quit."
    exit $EXIT_SUCCESS
    ;;

  b | B)
	echo "Backup persist parition"
	adb shell "dd if=/dev/block/platform/msm_sdcc.1/by-name/persist of=/data/persist.img"
	QSN_ID=$(adb shell "cat /persist/qsn_id")
	adb pull /data/persist.img persist-${QSN_ID}.img
    ;;

  p | P)
	echo "Restore persist parition"
	fastboot flash persist persist.img
	fastboot flash qsns persist.img
	;;

  m | M)
	echo "Backup modem paritions"
	QSN_ID=$(adb shell "cat /persist/qsn_id")
	adb shell "dd if=/dev/block/platform/msm_sdcc.1/by-name/modemst1 of=/data/modemst1.img"
	adb pull /data/modemst1.img modemst1-${QSN_ID}.img
	adb shell "dd if=/dev/block/platform/msm_sdcc.1/by-name/modemst2 of=/data/modemst2.img"
	adb pull /data/modemst2.img modemst2-${QSN_ID}.img
	adb shell "dd if=/dev/block/platform/msm_sdcc.1/by-name/fsg of=/data/fsg.img"
	adb pull /data/fsg.img fsg-${QSN_ID}.img
    ;;

  o | O)
	echo "Restore modem paritions"
	fastboot flash modemst1 modemst1.img
	fastboot flash modemst2 modemst2.img
	fastboot flash fsg fsg.img
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
