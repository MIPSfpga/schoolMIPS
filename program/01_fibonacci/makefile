# schoolMIPS makefile
# Stanislav Zhelnio, 2017
#
# based on:
#      makefile for MIPSfpga

help:
	$(info make help       - show this message)
	$(info make all        - alternative for: build size disasm readmemh)
	$(info make build      - build program.elf from sources)
	$(info make size       - show program size information)
	$(info make disasm     - disassemble program.elf )
	$(info make readmemh   - create verilog memory init file for simulation)
	$(info make clean      - delete all created files)
	$(info make board      - copy program file to board folder)
	$(info make modelsim   - simulate program and device using Modelsim)
	$(info make icarus     - simulate program and device using Icarus Verilog)
	$(info make gtkwave    - show the result of Icarus Verilog simulation in GTKWave)
	@true

#########################################################
# Path and program settings

CC = mips-mti-elf-gcc
LD = mips-mti-elf-gcc
OD = mips-mti-elf-objdump
OC = mips-mti-elf-objcopy
SZ = mips-mti-elf-size

#OS dependent
# sed
SED = sed
ifeq ($(OS), Windows_NT)
	SED  = ../../scripts/bin/sed
endif

#########################################################
# Compile settings and tasks
# -nostdlib		- no standard library
# -EL           - Little-endian
# -march=mips32 - schoolMIPS = MIPS 32 architecture
# -T program.ld - set up the link addresses for a bootable program
CFLAGS  = -nostdlib -EL -march=mips32 
LDFLAGS = -nostdlib -EL -march=mips32 -T program.ld

ASOURCES= \
main.S

AOBJECTS = $(ASOURCES:.S=.o)

.S.o:
	$(CC) -c $(CFLAGS) $< -o $@

.PHONY: clean sim

all: build size disasm readmemh

build :   program.elf
disasm:   program.dis
readmemh: program.hex

program.elf : $(AOBJECTS)
	$(LD) $(LDFLAGS) $(AOBJECTS) -o program.elf

program.dis: program.elf
	$(OD) -M no-aliases -Dz program.elf > program.dis

program.hex : program.elf
	echo @00000000 > program.hex
	$(OD) -Dz program.elf | $(SED) -rn 's/\s+[a-f0-9]+:\s+([a-f0-9]*)\s+.*/\1/p' >> program.hex

size: program.elf
	$(SZ) program.elf

board: program.hex
	rm -f ../../board/program/program.hex
	cp ./program.hex ../../board/program

clean:
	rm -rf sim
	rm -f *.o
	rm -f program.elf
	rm -f program.map
	rm -f program.dis
	rm -f program.hex
	rm -f program.rec

#########################################################
# Modelsim simulation

modelsim: program.hex program.dis
	rm -rf sim
	mkdir sim
	cp *.hex sim
	cd sim && vsim -do ../modelsim_script.tcl

#########################################################
# Icarus verilog simulation

TOPMODULE=sm_testbench
IVARG = -g2005 
IVARG += -D SIMULATION
IVARG += -D ICARUS
IVARG += -I ../../../src
IVARG += -I ../../../testbench
IVARG += -s $(TOPMODULE)
IVARG += ../../../src/*.v
IVARG += ../../../testbench/*.v

icarus: program.hex
	rm -rf sim
	mkdir sim
	cp *.hex sim
	cd sim && iverilog $(IVARG)
	cd sim && vvp -la.lst -n a.out -vcd
	
gtkwave: icarus
	cd sim && gtkwave dump.vcd

#########################################################
# How to make a bat replacement
#  make --no-print-directory -n debug > debug.bat
#  make --no-print-directory -n debug > attach.bat
