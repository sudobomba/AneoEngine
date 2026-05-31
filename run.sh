#!/bin/bash
set -e

echo "Running cd.iso"
qemu-system-i386 -m 512M -cdrom cd.iso -vga std -vnc :1
