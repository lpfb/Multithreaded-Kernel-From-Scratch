# Change this variable
PROJECT_NAME=section3-15

# Downt change the below lines
BUILD_PATH=/home/builder/bin/$(PROJECT_NAME)

all:
	@mkdir -p $(BUILD_PATH)
	nasm -f bin ./boot.asm -o $(BUILD_PATH)/boot.bin
	dd if=./massage.txt >> $(BUILD_PATH)/boot.bin
	dd if=/dev/zero bs=512 count=1 >> $(BUILD_PATH)/boot.bin

exec:
	qemu-system-x86_64 -hda $(BUILD_PATH)/boot.bin

# Get bint content
bless:
	bless $(BUILD_PATH)/boot.bin

clean:
	rm -rf $(BUILD_PATH)
