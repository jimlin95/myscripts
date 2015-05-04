#!/bin/bash
# create new git repo

sudo -u www-data mkdir $1 
cd $1
sudo -u www-data git --bare init 
echo "Create $1 git repository Done"
exit 0
