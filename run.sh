#!/bin/bash

set -xue

# QEMU のファイルパス
QEMU=qemu-system-riscv32

# QEMU を起動
$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot

