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

`define SM_CONFIG_ROM_SIZE  128

`define SM_CONFIG_EXCEPTION_HANDLER_ADDR    32'h100

`define SM_CONFIG_PIPELINE

//`define SM_CONFIG_BUSY_RAM
`define SM_CONFIG_BUSY_RAM_DELAY 2

`define SM_CONFIG_AHB_LITE

`define SM_CONFIG_SCRATCHPAD

`define SM_CONFIG_AHB_GPIO
//`define SM_CONFIG_AHB_GPIO_WIDTH 8

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

`ifdef SM_CONFIG_PIPELINE
    `define SM_CPU sm_pcpu
    `define SM_FORCE_RF_RDW
`else
    `define SM_CPU sm_cpu
`endif

`ifdef SM_CONFIG_BUSY_RAM
    `define SM_RAM sm_ram_busy
`elsif SM_CONFIG_AHB_LITE
    `ifdef SM_CONFIG_SCRATCHPAD
        `define SM_RAM sm_matrix
    `else
        `define SM_RAM sm_ahb_master
    `endif
`else
    `define SM_RAM sm_ram_fast
`endif

`ifdef SM_CONFIG_AHB_GPIO_WIDTH
    `define SM_GPIO_WIDTH SM_CONFIG_AHB_GPIO_WIDTH
`else
    `define SM_GPIO_WIDTH 8
`endif
