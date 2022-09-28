# Arch Linux UEFI-Bootable USB

## Usage

1. Prepare USB for UEFI booting. `sdb` is the device name of my USB stick. Your device name may vary, so make sure with `lsblk` before and after inserting the USB stick that the name of the device corresponds to the name you enter as an argument. **THIS IS A DESTRUCTIVE OPERATION! ALL DATA ON THE USB STICK WILL BE ERASED WITH THIS SCRIPT!**

        ./make_arch_linux_usb.sh <ENTER_USB_DEVICE_NAME>

    e. g.

        ./make_arch_linux_usb.sh sdb

    where `sdb` is the device name of the USB drive given by `lsblk` command.

1. List USB devices before and after inserting the USB stick to determine the device name. Then choose this device for the arch_linux installation.

    quick and sufficiently detailed listing

        $ lsblk -o NAME,FSTYPE,FSVER,UUID,MOUNTPOINT
        NAME   FSTYPE FSVER UUID                                 MOUNTPOINT
        sda                                                      
        ├─sda1 vfat   FAT32 220C-B8F7                            /boot
        └─sda2 ext4   1.0   cb217b7c-f7c0-4dae-b9a6-412e68b52408 /
        sdb                                                      
        └─sdb1 vfat   FAT32 B0F1-03FD                            


    or quick listing

        $ lsblk
        NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
        sda      8:0    0 238.5G  0 disk 
        ├─sda1   8:1    0   600M  0 part /boot
        └─sda2   8:2    0   220G  0 part /
        sdb      8:16   1   1.9G  0 disk 
        └─sdb1   8:17   1   1.9G  0 part

    or for another type of output

        $ lsblk --fs
        NAME   FSTYPE FSVER LABEL      UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
        sda                                                                                
        ├─sda1 vfat   FAT32            220C-B8F7                             356.3M    41% /boot
        └─sda2 ext4   1.0              cb217b7c-f7c0-4dae-b9a6-412e68b52408    7.5G    91% /
        sdb                                                                                
        └─sdb1 vfat   FAT32 arch_linux B0F1-03FD

    In my case the USB stick I inserted has the name `sdb`

---

The order of the operations matters.

I made this guide for arch_linux, but this can apply for any other UEFI bootable USB drive creation:

1. partition usb drive as gpt with one fat32 partition
2. download latest arch_linux in alternative, i.e. Ubuntu, version
3. extract the archive onto the usb drive
4. at the end, set the flags `boot` and `esp` for the fat32 partition on the USB drive; If you'd set the mentioned flags before mounting the USB in order to extract the arch_linux archive to the fat32 partition, the partition will not mount and the extraction fails, even when mounted as the root user into `/mnt/` - the extraction succeeds when the fat32 partition is not flagged or flagged as `msftdata`

## Sources

- https://archlinux.org/download/
- https://geo.mirror.pkgbuild.com/iso/2022.09.03/
- https://www.linuxquestions.org/questions/linux-general-1/how-to-use-a-%2A-sig-file-259395/
- https://www.wikihow.com/Verify-a-GPG-Signature

