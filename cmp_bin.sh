#!/bin/bash 
cmp -l $1 $2 | awk '{printf "%08X %02X %02X\n", $1, strtonum(0$2), strtonum(0$3)}'
