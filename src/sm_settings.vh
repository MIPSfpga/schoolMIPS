/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio
 */ 

//**************************************************************
// settings START

// instruction memory size (in words)
`define SM_CONFIG_ROM_SIZE  128

// default exception handler addr
`define SM_CONFIG_EXCEPTION_HANDLER_ADDR    32'h100

// CPU version: -single cycle
//              -pipelined
// (comment for single cycle)
`define SM_CONFIG_PIPELINE

// Memory options
// uncomment one of the allowed configurations:
// A. default block RAM
//`define SM_CONFIG_RAM_BLOCK
// B. block RAM with delayed READY signal
//`define SM_CONFIG_RAM_BUSY
// C. AHB devices (delayed block ram. gpio, etc) 
//`define SM_CONFIG_RAM_AHB
// D. the same but with a Scratchpad RAM
`define SM_CONFIG_RAM_AHB_AND_SCRATCH

// -------------------------------------------------------------
// Memory map
// Decode based on most significant bits of the address

// 1. internal sm_matrix (caches and ahb_master):
// 1.1 Scratchpad RAM   : 0x00000000 - 0x1fffffff   
// 1.2 AHB-Lite devices : 0x20000000 - 0xffffffff
`define SM_MEM_SCRATCHPAD ( addr [31:29] == 3'b000 )

// 2. external ahb_matrix (peripheral devices)
// 2.1 RAM              : 0x20000000 - 0x3fffffff
`define SM_MEM_AHB_RAM    ( addr [31:29] == 3'b001 )
// 2.2 GPIO             : 0x40000000 - 0x40000fff
`define SM_MEM_AHB_GPIO   ( addr [31:12] == 20'h40000 )

// settings END
//**************************************************************

// mode dependent values
`ifdef SM_CONFIG_PIPELINE
    `define SM_CPU sm_pcpu
    `define SM_FORCE_RF_RDW
`else
    `define SM_CPU sm_cpu
`endif

`ifdef SM_CONFIG_RAM_BLOCK
    `undef  SM_CONFIG_BUSY_RAM
    `undef  SM_CONFIG_AHB_LITE
    `undef  SM_CONFIG_SCRATCHPAD

    `define SM_RAM sm_ram_outbuf
`endif

`ifdef SM_CONFIG_RAM_BUSY
    `define SM_CONFIG_BUSY_RAM
    `undef  SM_CONFIG_AHB_LITE
    `undef  SM_CONFIG_SCRATCHPAD

    `define SM_RAM sm_ram_busy
`endif

`ifdef SM_CONFIG_RAM_AHB
    `undef  SM_CONFIG_BUSY_RAM
    `define SM_CONFIG_AHB_LITE
    `undef  SM_CONFIG_SCRATCHPAD

    `define SM_RAM sm_ahb_master
    `define SM_CONFIG_AHB_GPIO
`endif

`ifdef SM_CONFIG_RAM_AHB_AND_SCRATCH
    `undef  SM_CONFIG_BUSY_RAM
    `define SM_CONFIG_AHB_LITE
    `define SM_CONFIG_SCRATCHPAD

    `define SM_RAM sm_matrix
    `define SM_CONFIG_AHB_GPIO
`endif

// default values
`ifndef SM_CONFIG_BUSY_RAM_DELAY
    `define SM_CONFIG_BUSY_RAM_DELAY 3
`endif

`ifndef SM_GPIO_WIDTH
    `define SM_GPIO_WIDTH            8
`endif

