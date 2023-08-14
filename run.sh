#!/bin/bash

set -xue

# QEMU のファイルパス
QEMU=qemu-system-riscv32
# ls $(brew --prefix)/opt/llvm/bin/clang
# CC=/usr/local/opt/llvm/bin/clang
# on Ubuntu
CC=$(which clang)

CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32 -ffreestanding -nostdlib"

# build the kernel
$CC $CFLAGS -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf \
    kernel.c common.c

# QEMU を起動
$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
    -d unimp,guest_errors,int,cpu_reset -D qemu.log \
    -kernel kernel.elf
