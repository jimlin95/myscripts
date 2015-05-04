#!/bin/bash
#
# Program:
#       Make symbolic link for tsunami odm_kit
#
#	Usage: ./external_link.sh
#       
# History:
# 2010/01/14	Jim Lin,	First release
#-----------------------------------------------------------------------------------------------------
# Definition values
#-----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null
#-----------------------------------------------------------------------------------------------------
# Local definitions
#-----------------------------------------------------------------------------------------------------
CROSS_COMPILE="/opt/toolchains/tegra2-4.3.2-nv/bin/arm-none-linux-gnueabi-"
TARGET_ARCH="arm"
HHL_CROSS_COMPILE=".hhl_cross_compile"
HHL_TARGET_ARCH=".hhl_target_arch"
#SRC_PARENT=non-form-factor/trunk
if [ -z $1 ]; then
        SRC_PARENT=git-ff-trunk
else
        SRC_PARENT=$1
fi 
KERNEL_PATH=$SRC_PARENT/kernel
TSUNAMI=tsunami
ODM_KIT_PATH=$KERNEL_PATH/arch/arm/mach-tegra/odm_kit
USER_SPACE_ODM_KIT_PATH=$SRC_PARENT/userspace_odmkit_libs/vendor/nvidia/tsunami
BOOTLOADER_ODM_KIT_PATH=$SRC_PARENT/bootloader/fastboot/odm_kit
#-----------------------------------------------------------------------------------------------------
# Main function 
#-----------------------------------------------------------------------------------------------------
# create the configuration files for building kernel
echo $CROSS_COMPILE > $KERNEL_PATH/$HHL_CROSS_COMPILE
echo $TARGET_ARCH > $KERNEL_PATH/$HHL_TARGET_ARCH

#-----------------------------------------------------------------------------------------------------
# remove & make symbolic link for kernel odm_kit
#-----------------------------------------------------------------------------------------------------
if [ -h $ODM_KIT_PATH/$TSUNAMI ] ; then
	unlink $ODM_KIT_PATH/$TSUNAMI 
else
	rm  $ODM_KIT_PATH/$TSUNAMI -fr
fi 
ln -s ../../../../../odm_kit $ODM_KIT_PATH/$TSUNAMI 

#-----------------------------------------------------------------------------------------------------
# remove & make symbolic link for userspace odm_kit
#-----------------------------------------------------------------------------------------------------
if [ -h $USER_SPACE_ODM_KIT_PATH/ext_odm_kit ] ; then
	unlink $USER_SPACE_ODM_KIT_PATH/ext_odm_kit
fi 
ln -s ../../../../odm_kit  $USER_SPACE_ODM_KIT_PATH/ext_odm_kit

#-----------------------------------------------------------------------------------------------------
# remove & make symbolic link for  bootloader odm_kit
#-----------------------------------------------------------------------------------------------------
if [ -h $BOOTLOADER_ODM_KIT_PATH/$TSUNAMI ] ; then
	unlink  $BOOTLOADER_ODM_KIT_PATH/$TSUNAMI
else
	rm  $BOOTLOADER_ODM_KIT_PATH/$TSUNAMI -fr
fi 

ln -s ../../../odm_kit $BOOTLOADER_ODM_KIT_PATH/$TSUNAMI

#-----------------------------------------------------------------------------------------------------
exit $EXIT_SUCCESS
