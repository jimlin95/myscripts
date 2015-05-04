#!/bin/bash 
adb tcpip 5555
adb connect 192.168.11.${1}:5555
#adb shell
#adb usb
exit 0
