#!/bin/bash
cd /home/jim/uz1
rm rpm_proc.tar.gz trustzone_images.tar.gz
find rpm_proc/ -name "*.elf" | xargs tar czvf rpm_proc.tar.gz
find trustzone_images/ -name "*.elf" | xargs tar czvf trustzone_images.tar.gz
exit 0
