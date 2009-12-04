#!/bin/bash
# Program:
#       This program help to fetch image from git repository /home/daily/release_manager/repo ,and
#       wrapper release package 
#	Usage: ./fetch.sh 
#
# History:
# 2009/07/27	Jim Lin,	First release
# 2009/07/29	Jim Lin,	use parameters passing instead of tag_kernel and tag_redboot
# 2009/08/04	Jim Lin,	add fetching rootfs
# 2009/08/27	Jim Lin,	use android-rootfs
# Variables
CUR_DIR=$PWD
GIT_COMMAND="git checkout -f"
RELEASE=RELEASE
RELEASE_MANAGER=/home/daily/release_manager
REPO_DIR=$RELEASE_MANAGER/repo
SCRIPT_DIR=$RELEASE_MANAGER/script
MKSD_FILE=mkbootable_sd.sh
REDBOOT_DIR=$REPO_DIR/redboot
REDBOOT_CONFIG_DIR=$REPO_DIR/redboot_config
KERNEL_Rx_DIR=$REPO_DIR/kernel-Rx
KERNEL_ERx_DIR=$REPO_DIR/kernel-ERx
KERNEL_DIR=$KERNEL_Rx_DIR
REDBOOT_FILE=$REDBOOT_DIR/redboot.bin
REDBOOT_FILE_ONLY=redboot.bin
KERNEL_FILE=zImage
REDBOOT_CONFIG_FILE=$REDBOOT_CONFIG_DIR/redconfig.bin
KERNEL_LOG=kernel_build.log
REDBOOT_LOG=redboot_build.log
SDIMG_FILE=sd.img
REDBOOT_LOG=redboot_build.log
REDBOOT_SIZE=261120  # 256K- 1K =255K
SHA_FILE=SHA1_CODE
REDBOOT_PADDING=redboot_padding.bin
TEMP_FILE=zero_padding.bin
CUT_REDBOOT=redboot_cut.bin
REDBOOT_CONFIG_PADDING=redboot_config_padding.bin
TAG_REDBOOT=tag_redboot
TAG_KERNEL=tag_kernel
COMMIT_LOG_FILE=RELEASE.log
FC_ROOTFS_DIR=$REPO_DIR/fc-rootfs/rootfs
MILLOS_ROOTFS_DIR=$REPO_DIR/millos-rootfs/rootfs
ANDROID_ROOTFS_DIR=$REPO_DIR/android-rootfs/rootfs
THUNDERSOFT_ANDROID_ROOTFS_DIR=$REPO_DIR/ths-rootfs/rootfs
UBUNTU_ROOTFS_DIR=$REPO_DIR/ubuntu-rootfs/rootfs
ROOTFS_DIR=$FC_ROOTFS_DIR
ANDROID_SDCARD_DIR=$REPO_DIR/android_sdcard
REDBOOT_CONFIG_DEFAULT=master
REDBOOT_CONFIG_ANDROID_TAG=android
ZIMAGE_VER=master
REDBOOT_VER=master
ROOTFS_VER=master
LATEST_VER=master
REDBOOT_CONFIG_VER=$REDBOOT_CONFIG_DEFAULT
ROOTFS_TYPE=androidr2
IS_ANDOIRD=1
THUNDERSOFT_ROOTFS_TYPE=androidr4
ROOTFS_SUPPORT="freescale android millos ubuntu thundersoft"
ROOTFS_VERSION_FILE=.rootfs_sha

#function
error_exit()
{
	echo "Has ERRORs!!!Exit!!!"
	exit 1
}
showhelp() {
bn=`basename $0` 
ver=`echo '$Revision: 1.1 $' | sed 's/.Revision. \(.*\)./\1/'`
cat << eot
====================  $bn Version: $ver ==================

usage $bn [-h] [-k <zImage tag name>] [-r <redboot tag name>]
          [-n <rootfs tag name>] [-g <redboot config tag name>]
          [-k <zImage tag name> ] [-f <rootfs type>][-C DIR]
          [-b <app type> ][-t <app type> ]
  -h                             displays this help message
  -k <zImage tag name>           the tag name for fetch kernel image
  -r <redboot tag name>          the tag name for fetch redboot image
  -g <redboot config tag name>   the tag name for fetch redboot config
  -f <rootfs type>               root file system : androidr2, 
                                 androidr3, androidr4 ,freescale, 
                                 millos, ubuntu, thundersoft
  -n <rootfs tag name>           the tag name for fetch rootfs
  -C DIR                         change to directory DIR [Recomment 
                                 use this paramater]
  -b <app type>                  list branches (app type: android, thundersoft)
  -t <app type>                  list tags (app type: android, thundersoft)

eot
exit 1
}
checkout_specific_version()
{
	cd $REDBOOT_DIR
	echo "Processing redboot image ..."
	$GIT_COMMAND $REDBOOT_VER > /dev/null 2>&1
	if [ $? -ne 0 ]; then
        echo Checkout Redboot $REDBOOT_VER Error
		echo Maybe no $REDBOOT_VER tag
		error_exit
	fi 

	cd $KERNEL_DIR
    #android path
    if [ "$ZIMAGE_VER" = "master" ] && [ ${IS_ANDOIRD} -eq 1 ]; then    
        if [ "$ROOTFS_TYPE" = "thundersoft" ]; then
            $GIT_COMMAND branch_${THUNDERSOFT_ROOTFS_TYPE}
        else
            $GIT_COMMAND branch_$ROOTFS_INPUT
        fi

    else
	    $GIT_COMMAND $ZIMAGE_VER > /dev/null 2>&1
    fi
	if [ $? -ne 0 ];  then
	    echo Checkout Kernel $ZIMAGE_VER Error
		echo Maybe no $REDBOOT_VER tag
		error_exit
	fi 
	cd $REDBOOT_CONFIG_DIR

	$GIT_COMMAND branch_${REDBOOT_CONFIG_VER} > /dev/null 2>&1
	if [ $? -ne 0 ];  then
	    echo Checkout redboot config $REDBOOT_CONFIG_VER Error
		echo Maybe no $REDBOOT_CONFIG_VER tag
		error_exit
	fi 

#checkout rootfs specific version
	cd $ROOTFS_DIR
    if [ "$ROOTFS_VER" = "master" ] && [ "$ROOTFS_TYPE" = "android" ] ; then
        sudo $GIT_COMMAND branch_${ROOTFS_INPUT}  > /dev/null 2>&1
    else
    	sudo $GIT_COMMAND $ROOTFS_VER > /dev/null 2>&1    
    fi 

	if [ $? -ne 0 ];  then
	    echo Checkout rootfs $ROOTFS_VER Error
		echo Maybe no $ROOTFS_VER tag
		error_exit
	fi 
}
redboot_proces()
{
	dd if=$REDBOOT_FILE of=$CUR_DIR/$CUT_REDBOOT ibs=1K skip=1  2>/dev/null
	size=$(($REDBOOT_SIZE - $(stat -c %s $CUR_DIR/$CUT_REDBOOT)))
	dd if=/dev/zero of=$CUR_DIR/$TEMP_FILE bs=1 count=$size  2> /dev/null
	cat $CUR_DIR/$CUT_REDBOOT $CUR_DIR/$TEMP_FILE > $CUR_DIR/$REDBOOT_PADDING
	rm $CUR_DIR/$CUT_REDBOOT $CUR_DIR/$TEMP_FILE

}
md5_file_list_generate()
{
    cd $CUR_DIR
	echo -e "\n------------------- FILE MD5 LIST --------------------\n" >> $CUR_DIR/$RELEASE
	md5sum $REDBOOT_FILE_ONLY >> $CUR_DIR/$RELEASE
	md5sum $KERNEL_FILE >> $CUR_DIR/$RELEASE
    md5sum $SDIMG_FILE >> $CUR_DIR/$RELEASE
}
commit_message_log_fetch()
{
	echo -e "\n\n------------------- Redboot commit log----------------\n" >> $CUR_DIR/$RELEASE
	cat $REDBOOT_DIR/$COMMIT_LOG_FILE >> $CUR_DIR/$RELEASE
	echo -e "\n\n------------------- Kernel commit log ----------------\n" >> $CUR_DIR/$RELEASE
	cat $KERNEL_DIR/$COMMIT_LOG_FILE >> $CUR_DIR/$RELEASE
}
fetch_rootfs_sha()
{
	cd $ROOTFS_DIR
	echo -ne "${ROOTFS_TYPE}\t\t:" >> $CUR_DIR/$RELEASE
    ROOTFS_SHA=`git rev-parse --verify --short HEAD`
    echo  $ROOTFS_SHA >> $CUR_DIR/$RELEASE | 
	cd $CUR_DIR

}
release_file_generate()
{
	echo -ne "\nREDBOOT TAG NAME: "> $CUR_DIR/$RELEASE
    echo $REDBOOT_VER >> $CUR_DIR/$RELEASE
	echo "CONFIG  TAG NAME: $REDBOOT_CONFIG_VER" >> $CUR_DIR/$RELEASE
	echo "KERNEL  TAG NAME: $ZIMAGE_VER" >> $CUR_DIR/$RELEASE
	echo "ROOTFS  TAG NAME: $ROOTFS_VER" >> $CUR_DIR/$RELEASE

	echo -e "\n------------------- SHA CODE LIST --------------------\n" >> $CUR_DIR/$RELEASE
	echo -ne "redboot\t\t:" >> $CUR_DIR/$RELEASE
    REDBOOT_SHA=`cat $REDBOOT_DIR/SHA1_CODE`
    echo $REDBOOT_SHA >> $CUR_DIR/$RELEASE
	echo -ne "kernel\t\t:" >> $CUR_DIR/$RELEASE
    KERNEL_SHA=`cat $KERNEL_DIR/SHA1_CODE`
    echo $KERNEL_SHA >> $CUR_DIR/$RELEASE
	fetch_rootfs_sha
}

original_image_copy()
{

	cp $REDBOOT_DIR/$REDBOOT_LOG $CUR_DIR
	cp $REDBOOT_FILE $CUR_DIR
	cp $KERNEL_DIR/$KERNEL_LOG $CUR_DIR
	cp $KERNEL_DIR/$KERNEL_FILE $CUR_DIR
	cp $SCRIPT_DIR/$MKSD_FILE $CUR_DIR
	rm $CUR_DIR/$REDBOOT_PADDING
}
sd_image_generate()
{
	echo "SD image generating ..."
	cat $CUR_DIR/$REDBOOT_PADDING $REDBOOT_CONFIG_FILE $KERNEL_DIR/$KERNEL_FILE > $CUR_DIR/$SDIMG_FILE
}

zip_all_files()
{
	echo "tar packages ..."
	cd $CUR_DIR
	tar cjvf "release_r"$REDBOOT_SHA"_k"$KERNEL_SHA".tar.bz2" --exclude=fetch.sh  * >/dev/null 2>&1 
	cd $ROOTFS_DIR
    if [ $IS_ANDOIRD -eq 1 ]; then
        sudo chmod 777 * -R
    fi
    #generate rootfs sha file    
    echo "$ROOTFS_SHA" > $ROOTFS_VERSION_FILE 
    sudo tar cpjvf $CUR_DIR/rootfs-${ROOTFS_INPUT}-${ROOTFS_SHA}.tar.bz2 *  $ROOTFS_VERSION_FILE >/dev/null 2>&1 
	case $ROOTFS_TYPE in
		freescale)		
				;;
		android)
			cd $ANDROID_SDCARD_DIR
			tar cjvf $CUR_DIR/android_sdcard.tar.bz2 * >/dev/null 2>&1 
				;;
      thundersoft)
			cd $ANDROID_SDCARD_DIR
			tar cjvf $CUR_DIR/android_sdcard.tar.bz2 * >/dev/null 2>&1 
				;;
		   millos)
				;;
		   ubuntu)
				;;
	        *)
				echo 'ERROR!!!!UNKNOWN root file sytem type'
				;;			
	esac
}

restore2latest()
{
	echo restore to the lateset version
	cd $REDBOOT_DIR
	echo "Restore to the latest version  ..."
	$GIT_COMMAND $LATEST_VER > /dev/null 2>&1
	if [ $? -ne 0 ]; then
        echo Restore redboot to $LATEST Error
		error_exit
	fi 

	cd $KERNEL_DIR
	$GIT_COMMAND $LATEST_VER > /dev/null 2>&1
	if [ $? -ne 0 ];  then
	    echo Checkout Kernel $LATEST Error
		error_exit
	fi
	cd $REDBOOT_CONFIG_DIR
	$GIT_COMMAND $LATEST_VER > /dev/null 2>&1
	if [ $? -ne 0 ];  then
	    echo Checkout redboot config $LATEST Error
		error_exit
	fi  
	cd 	$ROOTFS_DIR	
	sudo $GIT_COMMAND $LATEST_VER > /dev/null 2>&1
	if [ $? -ne 0 ];  then
	    echo Checkout ROOTFS $LATEST Error
		error_exit
	fi 

}
PARA_IN=(r g k n)
ANDROID_PROCESS_DIR=($REDBOOT_DIR $REDBOOT_CONFIG_DIR $KERNEL_Rx_DIR $ANDROID_ROOTFS_DIR)
function android_branch_tag_show()
{
    i=0
    for name in ${ANDROID_PROCESS_DIR[@]};
    do 
        cd $name
        if [ "$1" == "branch" ]; then
            echo ">>> BRANCHs List in $name (with -${PARA_IN[$i]})"
            git branch -l
        else
            echo ">>> TAGs List in $name (with -${PARA_IN[$i]})"
            git tag
        fi

        i=`expr $i + 1`
    done    
}
THUNDERSOFT_PARA_IN=(r g k n)
THUNDERSOFT_PROCESS_DIR=($REDBOOT_DIR $REDBOOT_CONFIG_DIR $KERNEL_Rx_DIR $THUNDERSOFT_ANDROID_ROOTFS_DIR)
function thundersoft_branch_tag_show()
{
    i=0
    for name in ${THUNDERSOFT_PROCESS_DIR[@]};
    do 
        cd $name
        if [ "$1" == "branch" ]; then
            echo ">>> BRANCHs List in $name (with -${THUNDERSOFT_PARA_IN[$i]})"
            git branch -l
        else
            echo ">>> TAGs List in $name (with -${THUNDERSOFT_PARA_IN[$i]})"
            git tag
        fi

        i=`expr $i + 1`
    done    
}

#-------------------------------------------------------------------------
#main 

#--------------------- parse command line arguments ----------------------
## This loop works only if all switches are preceeded with a "-"
##
REDBOOT_CONFIG_CHANGE=0
while getopts hk:r:f:C:f:n:g:b:t: option
do
	case $option in
	    h) showhelp 
			;;
		k) ZIMAGE_VER="$OPTARG"
			;;
	    r) REDBOOT_VER="$OPTARG"
			;;
	    g) REDBOOT_CONFIG_VER="$OPTARG"
		   REDBOOT_CONFIG_CHANGE=1;
			;;
		f) ROOTFS_INPUT="$OPTARG" 
			;;
		n) ROOTFS_VER="$OPTARG" 
			;;
		C) NEW_DIR="$OPTARG"
			;;     		    
        b) APP_TYPE="$OPTARG"
            if [ "$APP_TYPE" = "android" ]; then        
                android_branch_tag_show "branch"
            fi
            if [ "$APP_TYPE" = "thundersoft" ]; then        
                thundersoft_branch_tag_show "branch"
            fi 
            exit 0
            ;;
        t) APP_TYPE_TAG="$OPTARG" 
            if [ "$APP_TYPE_TAG" = "android" ]; then        
                android_branch_tag_show "tag"
            fi
            if [ "$APP_TYPE_TAG" = "thundersoft" ]; then        
                thundersoft_branch_tag_show "tag"
            fi 
            exit 0
            ;;     		    
		\?) showhelp
			;;
	esac
done
#filter rootfile type

if [ -z $ROOTFS_INPUT ]; then
    echo "Please specific rootfs with -f"
    exit 1
fi
for ROOTFS_CHECK in $ROOTFS_SUPPORT
do 
    ISFOUND=`echo $ROOTFS_INPUT | grep $ROOTFS_CHECK -c`
    if [ $ISFOUND -gt 0 ]; then
        ROOTFS_TYPE=$ROOTFS_CHECK            
        break;
    fi
done

#-------------------------------------------------------------------------

#Assign ROOTFS Directory

case $ROOTFS_TYPE in
	freescale)
  		if [ $REDBOOT_CONFIG_CHANGE -eq 0 ]; then
		    REDBOOT_CONFIG_VER="others"
			cd $CUR_DIR
		fi
		ROOTFS_DIR=$FC_ROOTFS_DIR
		KERNEL_DIR=$KERNEL_ERx_DIR	
        IS_ANDOIRD=0
		;;
	android)
		if [ $REDBOOT_CONFIG_CHANGE -eq 0 ]; then
			#fetch the tag (android) to fit rootfs
			cd $REDBOOT_CONFIG_DIR
			#REDBOOT_CONFIG_VER=`git tag -l | grep android | sort -n | tail -1 `
            REDBOOT_CONFIG_VER="android"
			cd $CUR_DIR
		fi
		ROOTFS_DIR=$ANDROID_ROOTFS_DIR
		KERNEL_DIR=$KERNEL_Rx_DIR
        IS_ANDOIRD=1
		;;

	thundersoft)
		if [ $REDBOOT_CONFIG_CHANGE -eq 0 ]; then
			#fetch the tag (android) to fit rootfs
			cd $REDBOOT_CONFIG_DIR
			#REDBOOT_CONFIG_VER=`git tag -l | grep android | sort -n | tail -1 `
            REDBOOT_CONFIG_VER="android"
			cd $CUR_DIR
		fi		
		ROOTFS_DIR=$THUNDERSOFT_ANDROID_ROOTFS_DIR
		KERNEL_DIR=$KERNEL_Rx_DIR
        IS_ANDOIRD=1
		;;
	   millos)
		if [ $REDBOOT_CONFIG_CHANGE -eq 0 ]; then
		    REDBOOT_CONFIG_VER="others"
			cd $CUR_DIR
		fi
		ROOTFS_DIR=$MILLOS_ROOTFS_DIR
		KERNEL_DIR=$KERNEL_ERx_DIR
        IS_ANDOIRD=0    
		;;
	   ubuntu)
   		if [ $REDBOOT_CONFIG_CHANGE -eq 0 ]; then
		    REDBOOT_CONFIG_VER="others"
			cd $CUR_DIR
		fi
		ROOTFS_DIR=$UBUNTU_ROOTFS_DIR
		KERNEL_DIR=$KERNEL_ERx_DIR
        IS_ANDOIRD=0
		;;
        *)
		echo 'ERROR!!!!UNKNOWN root file sytem type'
		exit 1
		;;			
esac

echo "ZIMAGE_VER        =	$ZIMAGE_VER"
echo "REDBOOT_VER       =	$REDBOOT_VER"
echo "ROOTFS_VER        =	$ROOTFS_VER"
echo "REDBOOT_CONFIG_VER= 	$REDBOOT_CONFIG_VER"
echo "NEW_DIR           =	$NEW_DIR"
echo "ROOTFS_TYPE       =	$ROOTFS_TYPE"

if [ -n "$NEW_DIR" ]; then
	CUR_DIR=$CUR_DIR/$NEW_DIR
	mkdir $NEW_DIR
	if [ $? -ne 0 ]; then
		echo "Create $NEW_DIR fail"
		exit 1
	fi
fi

#process checkout actions
checkout_specific_version
#Processing redboot image
redboot_proces
#generate RELEASE file
release_file_generate
#generate sd.img file
sd_image_generate
#copy original image from repo
original_image_copy
#generate md5 
md5_file_list_generate
#generate commit message
commit_message_log_fetch
#compress all files 
zip_all_files
#restore to the latest version
restore2latest

echo "Success !!! Finished! ..."
exit 0
