# Change this variable
PROJECT_NAME=hello_world_bootloader

# Downt change the below lines
BUILD_PATH=/home/builder/bin/$(PROJECT_NAME)

all:
	@mkdir -p $(BUILD_PATH)
	nasm -f bin ./boot.asm -o $(BUILD_PATH)/boot.bin

exec:
	qemu-system-x86_64 -hda $(BUILD_PATH)/boot.bin

clean:
	rm -rf $(BUILD_PATH)
