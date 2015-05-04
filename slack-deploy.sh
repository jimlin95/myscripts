#!/bin/bash
CHANNEL="general"
if [ "$1" != "" ]; then
	CHANNEL=$1
fi
find -name "*.git" > dir.txt
cat dir.txt | while read line
do
echo $line
pushd $line
sudo unlink ./hooks/post-receive
sudo -u pirun ln -s /home/lcadmin/bin/post-receive hooks/post-receive
git config hooks.slack.channel  $CHANNEL
popd 
done
exit 0
