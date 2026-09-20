#!/bin/bash

sudo mount --rbind /dev debian-rootfs/dev
sudo mount --make-rslave debian-rootfs/dev

sudo mount -t proc /proc debian-rootfs/proc

sudo mount --rbind /sys debian-rootfs/sys
sudo mount --make-rslave debian-rootfs/sys

sudo mount --rbind /run debian-rootfs/run
sudo mount --make-rslave debian-rootfs/run

sudo chroot debian-rootfs /bin/bash
