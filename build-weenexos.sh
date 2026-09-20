#!/bin/bash
set -e

ROOTFS="$HOME/debian-rootfs"
BUILD="$HOME/weenexOS-iso"
ISO="$HOME/weenexOS.iso"

echo "==> Limpiando montajes del rootfs..."

sudo umount -R "$ROOTFS/dev" 2>/dev/null || true
sudo umount -R "$ROOTFS/proc" 2>/dev/null || true
sudo umount -R "$ROOTFS/sys" 2>/dev/null || true
sudo umount -R "$ROOTFS/run" 2>/dev/null || true

echo "==> Comprobando rootfs..."

if [ ! -f "$ROOTFS/etc/os-release" ]; then
    echo "ERROR: No encuentro $ROOTFS/etc/os-release"
    exit 1
fi

echo "==> Creando estructura de ISO..."

rm -rf "$BUILD"

mkdir -p "$BUILD/live"
mkdir -p "$BUILD/boot/grub"

echo "==> Buscando kernel..."

KERNEL=$(find "$ROOTFS/boot" -maxdepth 1 -name 'vmlinuz-*' -type f | sort -V | tail -n1)
INITRD=$(find "$ROOTFS/boot" -maxdepth 1 -name 'initrd.img-*' -type f | sort -V | tail -n1)

if [ -z "$KERNEL" ] || [ -z "$INITRD" ]; then
    echo "ERROR: No encuentro kernel o initramfs."
    exit 1
fi

echo "Kernel: $KERNEL"
echo "Initramfs: $INITRD"

echo "==> Copiando kernel e initramfs..."

cp "$KERNEL" "$BUILD/live/vmlinuz"
cp "$INITRD" "$BUILD/live/initrd.img"

echo "==> Creando filesystem.squashfs..."

sudo mksquashfs "$ROOTFS" \
    "$BUILD/live/filesystem.squashfs" \
    -comp zstd \
    -noappend

echo "==> Creando configuración de GRUB..."

cat > "$BUILD/boot/grub/grub.cfg" <<'EOF'
set timeout=5
set default=0

menuentry "weenexOS" {
    linux /live/vmlinuz boot=live quiet
    initrd /live/initrd.img
}
EOF

echo "==> Generando ISO BIOS + UEFI..."

grub-mkrescue \
    --xorriso=/usr/bin/xorriso \
    -o "$ISO" \
    "$BUILD"

echo
echo "======================================"
echo " ISO creada correctamente"
echo "======================================"
echo
echo "Archivo:"
echo "$ISO"
echo
ls -lh "$ISO"

