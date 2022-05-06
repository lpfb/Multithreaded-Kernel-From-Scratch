# Introduction
This file describes the assembly instructions for writing realmode bootloader

**Some instructions**

- ORG 0x7C00: offset bootloader address to its loading point. BIOS loads the bootloader to this address
- BITS 16: this instructs assembly to use 16 bit mode. This mode must be used in bootloader.
- 
- dw 0x55AA: must be added at the byte position 511-512, respectively, in order to be recognized by bios as a bootloader
