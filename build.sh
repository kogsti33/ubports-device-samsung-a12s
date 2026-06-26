#!/bin/bash
set -e

KERNEL_SRC="../kernel-samsung-a12s"
ARCH=arm64
DEFCONFIG="exynos850-a12snsxx_defconfig"
HALIUM_CONFIG="halium.config"
OUT="out"
JOBS=$(nproc)

echo "=== UBports kernel build for Samsung Galaxy A12s (Exynos 850) ==="

mkdir -p "$OUT"

echo "[1/5] Cloning kernel source..."
if [ ! -d "$KERNEL_SRC/Makefile" ]; then
    echo "ERROR: Kernel source not found at $KERNEL_SRC"
    exit 1
fi

echo "[2/5] Merging defconfig with halium.config..."
cd "$KERNEL_SRC"

cat arch/$ARCH/configs/$DEFCONFIG > /tmp/merged_defconfig
echo "" >> /tmp/merged_defconfig
echo "# Halium/UBports additions" >> /tmp/merged_defconfig
cat "$OLDPWD/$HALIUM_CONFIG" >> /tmp/merged_defconfig
cp /tmp/merged_defconfig arch/$ARCH/configs/ubports_a12s_defconfig

echo "[3/5] Building kernel..."
make ARCH=$ARCH ubports_a12s_defconfig
make ARCH=$ARCH -j$JOBS CC=aarch64-linux-gnu-gcc LD=aarch64-linux-gnu-ld AR=aarch64-linux-gnu-ar OBJCOPY=aarch64-linux-gnu-objcopy OBJDUMP=aarch64-linux-gnu-objdump NM=aarch64-linux-gnu-nm STRIP=aarch64-linux-gnu-strip Image modules 2>&1 | tail -20

echo "[4/5] Copying kernel image..."
mkdir -p "$OLDPWD/$OUT"
cp arch/$ARCH/boot/Image "$OLDPWD/$OUT/"
echo "Kernel image: $OLDPWD/$OUT/Image"

echo "[5/5] Build complete!"
echo ""
echo "Next steps:"
echo "  1. Extract offsets from stock boot.img"
echo "  2. Build boot.img with mkbootimg"
echo "  3. Flash via TWRP"
