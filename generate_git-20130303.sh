#!/bin/bash
# Program:
#    This program is an unitity for backup our working server
# 
#    Usage:  `basename $0` [src_dir] [fetch url] [dst dir] [default branch name]
#
#    Example: ./generate_git.sh /home/jim/projects/mtk/is6/alps git://10.241.119.3/mtk_jb2_is6 /home/jim/tmp/mtk_jb2_is6 
#               JB2.MP.V1.3_QUANTA89_WE_IS6_JB2
#
#  History:
#  2013/03/01    Jim Lin,    First release
# -----------------------------------------------------------------------------------------------------
# Definition values
# -----------------------------------------------------------------------------------------------------

EXIT_SUCCESS=0
EXIT_FAIL=1
NULL_DEV=/dev/null

# ----------------------------------------------------------------------------------------------------
# Local definitions
# -----------------------------------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------------------------------
# 
#SRC_DIR="/home/jim/mtk/alps"
SRC_DIR="/tmp/alps"
DateStamp=$(date +"%Y%m%d");
DST_DIR="/tmp/repository"
#FETCH_PATH="git://10.241.119.3/mtk-is6"
FETCH_PATH=$DST_DIR
DEFAULT_BRANCH="master"
#MYREPO="/tmp/MyRepo"
MYREPO="/home/jim/MyRepo"
MANIFEST_GIT="manifest"
MANIFEST_DEFAULT_XML="${MYREPO}/${MANIFEST_GIT}/default.xml"
PLATFORM="platform"
COMMIT_MESSAGE="Initial commit"


# -----------------------------------------------------------------------------------------------------
# Parameters check
# -----------------------------------------------------------------------------------------------------
# show help
if [ $# -gt 0 ]; then
	if [ "$1" == "-h" ]; then
		echo "Usage: `basename $0` [src_dir] [fetch url] [dst repo dir] [default branch name]"
		exit 0
	fi
fi

if [ $# -gt 0 ]; then
	SRC_DIR="${1}"
fi
if [ $# -gt 1 ]; then
	FETCH_PATH="${2}"
fi
if [ $# -gt 2 ]; then
	DST_DIR="${3}"
fi

if [ $# -gt 3 ]; then
	DEFAULT_BRANCH="${4}"
fi

# Update paramters
#FETCH_PATH="git://10.241.119.3/mtk-is6"

FETCH_PATH_TEMP=$DST_DIR


CORRECT_FETCH_PATH=$(echo $FETCH_PATH | sed -e "s/\//\\\\\//g")
CORRECT_FETCH_PATH_TEMP=$(echo $FETCH_PATH_TEMP | sed -e "s/\//\\\\\//g")

#exit 0
echo "******************************************************************"
echo "\$1: source path(absolut path)."
echo "     Default filename: ${SRC_DIR}"
echo "\$2 : fetch url (git server URL)."
echo "      Default URL: ${FETCH_PATH}"
echo "\$3 : output repository(absolut path)."
echo "      Default path: ${DST_DIR}"
echo "\$4 : default branch name."
echo "      Default name: ${DEFAULT_BRANCH}"
echo " "
echo "******************************************************************"
# -----------------------------------------------------------------------------------------------------
# Clean up
#rm $DST_DIR
# Create manifest.git
if [ ! -d $DST_DIR/manifest.git ];then
git init --bare $DST_DIR/manifest.git
fi
# -----------------------------------------------------------------------------------------------------
# Clone git-repo.git from Google
if [ ! -d $DST_DIR/git-repo.git ];then
git clone https://gerrit.googlesource.com/git-repo $DST_DIR/git-repo.git --bare
fi
PROJECT_LIST=$(find $SRC_DIR/* -maxdepth 0 -type d )

# Create bare git for all projects
cd $SRC_DIR
for dir in $PROJECT_LIST; 
do
	foldername=$(basename $dir);	
	echo $foldername
	git init --bare $DST_DIR/${PLATFORM}/${foldername}.git
done

# -----------------------------------------------------------------------------------------------------
# Customize manifest
git clone $DST_DIR/manifest.git ${MYREPO}/${MANIFEST_GIT}
echo '<?xml version="1.0" encoding="UTF-8"?>' > ${MANIFEST_DEFAULT_XML}
echo '<manifest>' >>  ${MANIFEST_DEFAULT_XML}
echo -e "\t<remote fetch=\"${FETCH_PATH_TEMP}\" name=\"qci\" />\n" >> ${MANIFEST_DEFAULT_XML}
echo -e "\t<default remote=\"qci\" revision=\"${DEFAULT_BRANCH}\" />\n" >> ${MANIFEST_DEFAULT_XML}
# Add projects to manifest default.xml


for dir in $PROJECT_LIST; 
do
	foldername=$(basename $dir);	
	copyfile_flag="false"
	echo $foldername	

	if [ $foldername == "build" ]; then
		echo -e "\t<project path=\"$foldername\" name=\"${PLATFORM}/${foldername}\" > " >> ${MANIFEST_DEFAULT_XML}
		echo -e "\t\t<copyfile dest=\"Makefile\" src=\"core/root.mk\"/>" >>${MANIFEST_DEFAULT_XML}
		echo -e "\t</project>" >> ${MANIFEST_DEFAULT_XML}
		copyfile_flag="true"
	fi
	if [ $foldername == "mediatek" ]; then
		echo -e "\t<project path=\"$foldername\" name=\"${PLATFORM}/${foldername}\" > " >> ${MANIFEST_DEFAULT_XML}
		echo -e "\t\t<copyfile dest=\"makeMtk\" src=\"build/makeMtk\"/>" >>${MANIFEST_DEFAULT_XML}
		echo -e "\t\t<copyfile dest=\"mbldenv.sh\" src=\"build/mbldenv.sh\"/>" >>${MANIFEST_DEFAULT_XML}
		echo -e "\t\t<copyfile dest=\"mk\" src=\"build/mk\"/>" >>${MANIFEST_DEFAULT_XML}
		echo -e "\t</project>" >> ${MANIFEST_DEFAULT_XML}
		copyfile_flag="true"
	fi
	if [ $copyfile_flag == "false" ]; then
	echo -e "\t<project path=\"$foldername\" name=\"${PLATFORM}/${foldername}\" /> " >> ${MANIFEST_DEFAULT_XML}	
	fi
done

echo '</manifest>' >>${MANIFEST_DEFAULT_XML}

# -----------------------------------------------------------------------------------------------------
# Add manifest.xml and push
cd ${MYREPO}/${MANIFEST_GIT}
git checkout --orphan $DEFAULT_BRANCH
git add --all
git commit -a -m 'add manifest.xml by script' -s
git push --all

# -----------------------------------------------------------------------------------------------------
# Customize all projects

for dir in $PROJECT_LIST; 
do
	cd ${MYREPO}
	foldername=$(basename $dir);	
	echo $foldername
	git clone ${FETCH_PATH_TEMP}/platform/${foldername}.git
	cd $foldername
	# copy files & commit & push .
	cp $SRC_DIR/$foldername/* . -r
	git checkout --orphan $DEFAULT_BRANCH
	git add --all 
	git commit -a -m "$COMMIT_MESSAGE" -s
	git push --all	
done

# -----------------------------------------------------------------------------------------------------
# Correct fetch path in manifest.xml  
TAB=$'\t' 
cd $MYREPO/manifest 
git checkout --orphan $DEFAULT_BRANCH
sed -i "s/fetch\=\"$CORRECT_FETCH_PATH_TEMP\"/fetch\=\"$CORRECT_FETCH_PATH\"/g" $MANIFEST_DEFAULT_XML
git commit -a -m 'update manifest.xml by script' -s --amend --allow-empty
# Need master branch as default branch in manifest.git 
if [ $DEFAULT_BRANCH != "master" ]; then
	git checkout -b master $DEFAULT_BRANCH
fi

git push --all -f

# Clean up

rm $MYREPO -fr

exit 0
