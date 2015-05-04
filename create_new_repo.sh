#!/bin/bash
REFERENCE=template
sudo svnadmin create $1 
sudo chown -R $1 --reference=$REFERENCE
echo "Create $1 repository Done"
exit 0
