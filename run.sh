#!/bin/bash

set -xue

# QEMU のファイルパス
QEMU=qemu-system-riscv32
if [[ "$OSTYPE" == "darwin"* ]]; then
  # ls $(brew --prefix)/opt/llvm/bin/clang
  CC=/usr/local/opt/llvm/bin/clang
else
  # on Ubuntu
  CC=$(which clang)
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  # ls $(brew --prefix)/opt/llvm/bin/llvm-objcopy
  OBJCOPY=/usr/local/opt/llvm/bin/llvm-objcopy
else
  OBJCOPY=$(which llvm-objcopy)
fi

CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32 -ffreestanding -nostdlib"

# build the shell
$CC $CFLAGS -Wl,-Tuser.ld -Wl,-Map=shell.map -o shell.elf shell.c user.c common.c
$OBJCOPY --set-section-flags .bss=alloc,contents -O binary shell.elf shell.bin
$OBJCOPY -Ibinary -Oelf32-littleriscv shell.bin shell.bin.o

# build the kernel
$CC $CFLAGS -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf \
    kernel.c common.c shell.bin.o

tar cf disk.tar --format=ustar --strip-components=1 disk

# QEMU を起動
$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
    -d unimp,guest_errors,int,cpu_reset -D qemu.log \
    -drive id=drive0,file=disk.tar,format=raw \
    -device virtio-blk-device,drive=drive0,bus=virtio-mmio-bus.0 \
    -kernel kernel.elf
