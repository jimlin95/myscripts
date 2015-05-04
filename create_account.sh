#!/bin/sh
case "$1" in
samba)
	echo "Create Samba and user account $2 start ....."
	adduser $2
	pdbedit -au $2
	echo "Create Samba and user account $2 end ....."
	;;
user)
	echo "Create user account $2 start ....."
	adduser $2
	echo "Create user account $2 end ....."
	;;
del)
	echo "Delete user account $2 start ....."
	deluser $2
	echo "Delete user account $2 end ....."
	;;
*)
	echo "Help >>"
	echo "./create_account.sh del USERNAME -> Delete user account"
	echo "./create_account.sh user USERNAME -> Only user account"
	echo "./create_account.sh samba USERNAME -> User + samba account"
	;;
esac
