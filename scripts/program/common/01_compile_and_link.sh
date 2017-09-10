#!/bin/bash

mips-mti-elf-gcc -nostdlib -EL -march=mips32 -T program.ld main.S -o program.elf
