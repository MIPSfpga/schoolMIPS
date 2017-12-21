/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio
 */ 

`define SM_CONFIG_PIPELINE



`ifdef SM_CONFIG_PIPELINE
    `define SM_CPU sm_pcpu
`else
    `define SM_CPU sm_cpu
`endif
