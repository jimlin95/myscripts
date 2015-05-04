#!/bin/bash 
./mkbootimg --kernel ./zImage --ramdisk ./ramdisk.img --cmdline 'console=ttyO2,115200n8 mem=456M@0x80000000 mem=512M@0xA0000000 init=/init vram=32M omapfb.vram=0:16M androidboot.hardware=omap4blazeboard androidboot.console=ttyO2' --base 0x80000000 --output boot.img 
