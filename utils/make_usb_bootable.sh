#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

echo "Set the partition name for easier recognition in the file manager and in the terminal"
echo "and in order to actually boot the Arch Linux USB because the bootloader is sensitive to partition label"
echo "which is set up as "ARCH_" + "FIRST_SIX_DIGITS_OF_THE_RELEASE_DATE""

PARTITION="/dev/$(cat /proc/partitions | grep "${DISK_NAME}" | grep -v "${DISK_NAME}"$ | tr -s ' \t' | rev | cut -d' ' -f1 | rev)"

latest_arch_linux_release_version=$(curl --silent https://archlinux.org/download/ | grep "Current Release" | cut --delimiter=':' --fields=2 | cut --delimiter=' ' --fields=2 | cut --delimiter='<' --fields=1 | tr --delete '.')

partition_label="ARCH_${latest_arch_linux_release_version:0:6}"
sudo fatlabel "${PARTITION}" "${partition_label}"

echo "Verification"
lsblk -o NAME,FSTYPE,LABEL,UUID "${DISK_DEVICE}"
echo "========================================="
sudo parted --script "${DISK_DEVICE}" print

