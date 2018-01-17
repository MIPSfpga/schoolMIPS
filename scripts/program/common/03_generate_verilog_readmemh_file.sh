#!/bin/bash

# 'objcopy -O verilog' produces the x8 output.
# As we need x32 we are getting it from disasm results

echo @00000000 > program.hex
mips-mti-elf-objdump -Dz program.elf | sed -rn 's/\s+[a-f0-9]+:\s+([a-f0-9]*)\s+.*/\1/p' >> program.hex
