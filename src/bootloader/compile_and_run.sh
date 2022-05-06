nasm -f bin boot.asm -o boot.bin

echo "Disassambling: ndisasm boot.bin"

qemu-system-x86_64 -hda boot.bin
