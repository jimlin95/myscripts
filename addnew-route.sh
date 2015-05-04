#!/bin/bash 
#for Dropbox
sudo route add -net 108.160.0.0 netmask 255.255.0.0  gw 192.168.100.1
sudo route add -net 194.68.0.0 netmask 255.255.0.0  gw 192.168.100.1
sudo route add -net 202.39.0.0 netmask 255.255.0.0  gw 192.168.100.1

sudo route add -net 198.100.0.0 netmask 255.255.0.0  gw 192.168.100.1
sudo route add -net 134.159.0.0 netmask 255.255.0.0  gw 192.168.100.1
#facebook
sudo route add -net 31.13.0.0 netmask 255.255.0.0  gw 192.168.100.1
#pchome
sudo route add -net 210.242.0.0 netmask 255.255.0.0  gw 192.168.100.1
exit 0
