#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

latest_arch_linux_release_version=$(curl --silent https://archlinux.org/download/ | grep "Current Release" | cut --delimiter=':' --fields=2 | cut --delimiter=' ' --fields=2 | cut --delimiter='<' --fields=1)

if [ ! -f "/tmp/arch_linux_latest.iso" ]
then
  printf "%s\n" "Downloading Arch Linux in version ${latest_arch_linux_release_version}"
  printf "%s\n\n" "https://geo.mirror.pkgbuild.com/iso/"${latest_arch_linux_release_version}"/archlinux-"${latest_arch_linux_release_version}"-x86_64.iso"

  axel --verbose --num-connections=10 \
      "https://geo.mirror.pkgbuild.com/iso/"${latest_arch_linux_release_version}"/archlinux-"${latest_arch_linux_release_version}"-x86_64.iso" --output="/tmp/arch_linux_latest.iso"
fi

echo "Downloading signature file for integrity verification of the downloaded archive"
curl --location https://geo.mirror.pkgbuild.com/iso/"${latest_arch_linux_release_version}"/archlinux-"${latest_arch_linux_release_version}"-x86_64.iso.sig --output "/tmp/arch_linux_latest.sig"

echo "Verifying integrity of the archive"
gpg --keyserver-options auto-key-retrieve --verify /tmp/arch_linux_latest.sig /tmp/arch_linux_latest.iso

curl --location https://geo.mirror.pkgbuild.com/iso/"${latest_arch_linux_release_version}"/sha256sums.txt --output "/tmp/arch_linux_latest-sha256sums.txt"
ARCH_LINUX_ISO_SHA256SUM_LOCAL="$(sha256sum /tmp/arch_linux_latest.iso | tr --squeeze-repeats ' ' | cut --delimiter=' ' --fields=1)"
ARCH_LINUX_ISO_SHA256SUM_REMOTE="$(grep --ignore-case "^$ARCH_LINUX_ISO_SHA256SUM_LOCAL" /tmp/arch_linux_latest-sha256sums.txt | head --lines=1)"

if [ -z "${ARCH_LINUX_ISO_SHA256SUM_REMOTE}" ]
then
  echo "File integrity compromised. Local and remote checksums are different."
  echo "Try to download the archive from different source and make sure the verification file is belonging to the archive you downloaded"
  exit 1
fi

echo
echo "*********************************************************************"
echo
echo "File integrity check passed. Local and remote checksums are matching."
echo "Proceeding..."
echo
echo "*********************************************************************"
echo

echo "Unmount all partitions of the device '/dev/${DISK_NAME}'"
PARTITION_NAME=$(cat /proc/partitions | grep "${DISK_NAME}" | rev | cut -d' ' -f1 | rev | grep -v ""${DISK_NAME}"$")
PARTITION_DEVICE="/dev/${PARTITION_NAME}"

udisksctl unmount --block-device ${PARTITION_DEVICE}
udisksctl mount --block-device ${PARTITION_DEVICE}
USB_MOUNT_DIR="$(lsblk -oNAME,MOUNTPOINTS "${PARTITION_DEVICE}" | tail --lines=1 | cut --delimiter=' ' --fields=1 --complement)/"

sudo 7z x -y "/tmp/arch_linux_latest.iso" -o"${USB_MOUNT_DIR}"

sync
sudo sync

udisksctl unmount --block-device ${PARTITION_DEVICE}

