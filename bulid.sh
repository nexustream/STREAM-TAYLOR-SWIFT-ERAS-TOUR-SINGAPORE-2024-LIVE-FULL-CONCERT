#!/bin/bash

echo "Downloading Necessary Files"
pkg update && pkg upgrade
pkg install build-essential git bc bison flex libssl-dev wget mtools syslinux

# Exit on any error
set -e

# Variables
KERNEL_VERSION="2.1.23"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v2.1/linux-$KERNEL_VERSION.tar.gz"
BUSYBOX_VERSION="1.33.1"
BUSYBOX_URL="https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2"
INSTALL_DIR="$HOME/kernel_build"
RAMDISK_DIR="$INSTALL_DIR/ramdisk"
STORAGE_DIR="/storage/emulated/0/TermuxOutput" # Adjust this path if needed
FLOPPY_IMG="$STORAGE_DIR/boot.img"

# Create directories
mkdir -p $INSTALL_DIR
mkdir -p $RAMDISK_DIR
mkdir -p $STORAGE_DIR

# Download and extract Linux kernel source
echo "Downloading and extracting Linux kernel $KERNEL_VERSION..."
cd $INSTALL_DIR
wget $KERNEL_URL
tar -xzf linux-$KERNEL_VERSION.tar.gz
cd linux-$KERNEL_VERSION

# Configure the kernel
echo "Configuring the kernel..."
make defconfig

# Compile the kernel
echo "Compiling the kernel..."
make -j$(nproc)

# Download and extract BusyBox
echo "Downloading and extracting BusyBox $BUSYBOX_VERSION..."
cd $INSTALL_DIR
wget $BUSYBOX_URL
tar -xjf busybox-$BUSYBOX_VERSION.tar.bz2
cd busybox-$BUSYBOX_VERSION

# Configure and compile BusyBox
echo "Configuring and compiling BusyBox..."
make defconfig
make -j$(nproc)
make install CONFIG_PREFIX=$RAMDISK_DIR

# Create ramdisk
echo "Creating ramdisk..."
cd $RAMDISK_DIR
mkdir -p dev proc sys tmp
mknod dev/console c 5 1
mknod dev/null c 1 3
find . | cpio -o --format=newc | gzip > $INSTALL_DIR/initramfs.gz

# Copy kernel and ramdisk to shared storage
echo "Copying kernel and ramdisk to shared storage..."
cp $INSTALL_DIR/linux-$KERNEL_VERSION/arch/x86/boot/bzImage $STORAGE_DIR
cp $INSTALL_DIR/initramfs.gz $STORAGE_DIR

# Create a bootable floppy image
echo "Creating bootable floppy image..."
dd if=/dev/zero of=$FLOPPY_IMG bs=1k count=1440
mkfs.msdos $FLOPPY_IMG
mcopy -i $FLOPPY_IMG $STORAGE_DIR/bzImage ::/linux
mcopy -i $FLOPPY_IMG $STORAGE_DIR/initramfs.gz ::/initrd.gz
syslinux --install $FLOPPY_IMG

# Create syslinux.cfg
echo "DEFAULT linux" > syslinux.cfg
echo "LABEL linux" >> syslinux.cfg
echo "  KERNEL /linux" >> syslinux.cfg
echo "  INITRD /initrd.gz" >> syslinux.cfg
echo "  APPEND root=/dev/ram0 rw" >> syslinux.cfg

mcopy -i $FLOPPY_IMG syslinux.cfg ::

# Output locations
echo "Kernel compiled at: $STORAGE_DIR/bzImage"
echo "Ramdisk created at: $STORAGE_DIR/initramfs.gz"
echo "Bootable floppy image created at: $FLOPPY_IMG Make Sure Test Your Emulator"

echo "Build complete."
