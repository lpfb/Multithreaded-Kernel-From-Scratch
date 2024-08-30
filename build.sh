#!/bin/bash

export PREFIX=$SDK_AND_COMPILER
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

make all
