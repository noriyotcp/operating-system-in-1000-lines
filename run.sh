#!/bin/bash

set -xue

# QEMU のファイルパス
QEMU=qemu-system-riscv32
# ls $(brew --prefix)/opt/llvm/bin/clang
# CC=/usr/local/opt/llvm/bin/clang
# on Ubuntu
CC=$(which clang)
# ls $(brew --prefix)/opt/llvm/bin/llvm-objcopy
# OBJCOPY=/usr/local/opt/llvm/bin/llvm-objcopy
OBJCOPY=$(which llvm-objcopy)

CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32 -ffreestanding -nostdlib"

# build the shell
$CC $CFLAGS -Wl,-Tuser.ld -Wl,-Map=shell.map -o shell.elf shell.c user.c common.c
$OBJCOPY --set-section-flags .bss=alloc,contents -O binary shell.elf shell.bin
$OBJCOPY -Ibinary -Oelf32-littleriscv shell.bin shell.bin.o

# build the kernel
$CC $CFLAGS -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf \
    kernel.c common.c shell.bin.o

# QEMU を起動
$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
    -d unimp,guest_errors,int,cpu_reset -D qemu.log \
    -kernel kernel.elf
