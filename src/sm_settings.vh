/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio
 */ 

`define SM_CONFIG_ROM_SIZE  128

`define SM_CONFIG_EXCEPTION_HANDLER_ADDR    32'h100

//`define SM_CONFIG_PIPELINE

`define SM_CONFIG_BUSY_RAM

`ifdef SM_CONFIG_PIPELINE
    `define SM_CPU sm_pcpu
    `define SM_FORCE_RF_RDW
`else
    `define SM_CPU sm_cpu
`endif

`ifdef SM_CONFIG_BUSY_RAM
    `define SM_RAM sm_ram_busy
`else
    `define SM_RAM sm_ram_fast
`endif
