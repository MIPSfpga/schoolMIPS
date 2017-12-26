#!/bin/bash

mips-mti-elf-objdump -M no-aliases -D program.elf > program.dis
