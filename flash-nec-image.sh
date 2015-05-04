adb shell "dd if=/dev/block/mmcblk0boot0 of=/sdcard/sdc.img"
adb pull /sdcard/sdc.img 
adb reboot-bootloader
fastboot -i 0x451 flash bootloader u-boot_STR-6.4.0.bin

fastboot -i 0x451 reboot-bootloader
sleep 2
fastboot -i 0x451 oem format
fastboot -i 0x451 flash xloader MLO_STR-6.4.0
fastboot -i 0x451 flash bootloader u-boot_STR-6.4.0.bin
fastboot -i 0x451 flash logoimage NEC-Logo.bmp
fastboot -i 0x451 erase efs
fastboot -i 0x451 erase log
fastboot -i 0x451 erase userdata
fastboot -i 0x451 erase cache
fastboot -i 0x451 erase system
fastboot -i 0x451 flash boot boot.img
fastboot -i 0x451 flash recovery recovery.img
fastboot -i 0x451 flash system system.img
fastboot -i 0x451 flash backup backup.img

fastboot -i 0x451 flash sdc sdc.img
fastboot -i 0x451 reboot


