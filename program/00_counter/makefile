# schoolMIPS makefile
# Stanislav Zhelnio, 2017
#
# based on:
#      makefile for MIPSfpga

help:
	$(info make help       - show this message)
	$(info make all        - alternative for: build size disasm readmemh copy)
	$(info make build      - build program.elf from sources)
	$(info make size       - show program size information)
	$(info make disasm     - disassemble program.elf )
	$(info make readmemh   - create verilog memory init file for simulation)
	$(info make clean      - delete all created files)
	$(info make copy       - copy program file to board folder)
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

all: build size disasm readmemh copy

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

copy: program.hex
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

modelsim:
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

icarus:
	rm -rf sim
	mkdir sim
	cp *.hex sim
	cd sim && iverilog $(IVARG)
	cd sim && vvp -la.lst -n a.out -vcd
	
gtkwave: icarus
	cd sim && gtkwave dump.vcd

##########################################################################################
##########################################################################################

# #########################################################
# # Compile settings and tasks

# # -EL           - Little-endian
# # -march=m14kc  - MIPSfpga = MIPS microAptiv UP based on MIPS M14Kc
# # -msoft-float  - should not use floating-point processor instructions
# # -O1           - optimization level
# # -std=c99		- C99 lang standard options enabled
# CFLAGS  = -EL -march=m14kc -msoft-float -O1 -std=c99 
# LDFLAGS = -EL -march=m14kc -msoft-float -Wl,-Map=program.map

# # -g -gdwarf-2  - debug symbols to use with gdb
# DBFLAGS = -g -gdwarf-2 

# # Set up the link addresses for a bootable C program on MIPSfpga
# LDFLAGS += -T program.ld
# # Place the boot code (physical address). The virtual address for
# # boot code entry point is hard-wired to 0x9fc00000.
# LDFLAGS += -Wl,--defsym,__flash_start=0xbfc00000
# # Place the application code (physical address)
# LDFLAGS += -Wl,--defsym,__flash_app_start=0x80000000
# # Place the application code (virtual address)
# LDFLAGS += -Wl,--defsym,__app_start=0x80000000

# # Set the stack to the top of the Code/Data RAM
# # stack depends on available mem size:
# #     256K -> 0x80040000 (simulation)
# #       8M -> 0x80800000 
# #      64M -> 0x84000000 (de10-lite)
# STACK   = 0x80040000
# LDFLAGS += -Wl,--defsym,__stack=$(STACK)

# # Cautiously set the size of memory as the 2015.01 toolchain uses
# # this size as the amount of free memory between the end of the
# # program data and the lowest address that the stack will reach.
# #
# # Max 2K for stack (0x800)
# # Max 128K for program code/data (0x20000)
# # Leaving 126K heap (0x1f800)
# LDFLAGS += -Wl,--defsym,__memory_size=0x1f800

# # Set the entry point to the true hard-reset address
# LDFLAGS += -Wl,-e,0xbfc00000

# ASOURCES= \
# boot.S

# CSOURCES= \
# main.c

# COBJECTS = $(CSOURCES:.c=.o)
# CASMS    = $(CSOURCES:.c=.s)
# AOBJECTS = $(ASOURCES:.S=.o)

# .PHONY: clean sim

# all: compile program size disasm readmemh srecord

# program : $(AOBJECTS) $(COBJECTS) 
# 	$(LD)  $(LDFLAGS) $(AOBJECTS) $(COBJECTS) $(DBFLAGS) -o program.elf

# .c.o:
# 	$(CC) -c $(CFLAGS) $(DBFLAGS) $< -o $@

# .S.o:
# 	$(CC) -c $(CFLAGS) $(DBFLAGS) $< -o $@

# .c.s:
# 	$(CC) -S $(CFLAGS) $< -o $@

# compile: $(CASMS)

# disasm:
# 	$(OD) -D -l program.elf > program.dis

# readmemh:
# 	$(OC) program.elf -O verilog program.hex
# 	$(HS)

#########################################################
# How to make a bat replacement
#  make --no-print-directory -n debug > debug.bat
#  make --no-print-directory -n debug > attach.bat
