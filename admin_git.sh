#!/bin/bash

MENU_ENTRY()
{
#  echo -e "\x1b[1;36m"
  echo -e "\x1b[1;36m=========================== Admin Git Site ===========================\x1b[0m"
  echo -e " a. \x1b[1;33mA\x1b[0mdd user account"
  echo -e " c. \x1b[1;33mC\x1b[0mhange user passwd"
  echo -e " d. \x1b[1;33mD\x1b[0mel user account"
  echo -e " p. \x1b[1;33mP\x1b[0mrint user list"
  echo -e " g. modify \x1b[1;33mG\x1b[0mroups"
  echo -e " s. switch git \x1b[1;33mS\x1b[0mite"
  echo -e " w. switch git \x1b[1;33mW\x1b[0meb"
  echo -e " r. \x1b[1;33mR\x1b[0meload apache "
  echo -e " q. \x1b[1;33mQ\x1b[0muit"
  echo -e "\x1b[1;36m=======================================================================\x1b[0m"
  echo -e "\x1b[0m \x1b[1;34m"
  read -p "Please enter your choice: " choice
  echo -e "\x1b[0m"

  case $choice in
  a)
	read -p "Please enter username: " username
	if [ -n "$username" ]
	then
    	sudo htpasswd /etc/apache2/passwd.git $username
	else
		echo -e "\x1b[1;31m username is null. \x1b[0m"
	fi
    MENU_ENTRY
    ;;
  c)
	read -p "Please enter username: " username
	if [ -n "$username" ]
	then
    	sudo htpasswd -d /etc/apache2/passwd.git $username
	else
		echo -e "\x1b[1;31m username is null. \x1b[0m"
	fi
    MENU_ENTRY
    ;;
  d)
	read -p "Please enter username: " username
	if [ -n "$username" ]
	then
    	sudo htpasswd -D /etc/apache2/passwd.git $username
	else
		echo -e "\x1b[1;31m username is null. \x1b[0m"
	fi
    MENU_ENTRY
    ;;
  p)
    cat /etc/apache2/passwd.git
    MENU_ENTRY
    ;;
  g)
    echo -e "\x1b[1;32m sudo vim /etc/apache2/htgroup.git \x1b[0m"
    MENU_ENTRY
    ;;
  s)
    echo -e "\x1b[1;32m sudo vim /etc/apache2/conf.d/git.conf \x1b[0m"
    MENU_ENTRY
    ;;
  w)
    echo -e "\x1b[1;32m sudo vim /etc/apache2/conf.d/gitweb \x1b[0m"
    MENU_ENTRY
    ;;
  r)
    sudo /etc/init.d/apache2 reload
    MENU_ENTRY
    ;;
  q)
    echo "Quit."
    exit 0
    ;;
  *)
    echo "Unknown choice."
    MENU_ENTRY
    ;;
  esac
}

MENU_ENTRY
