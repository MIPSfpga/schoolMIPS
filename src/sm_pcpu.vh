/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * the pipeline version of Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017-2018 Stanislav Zhelnio
 */ 

`define HZ_FW_ME    2'b10   // forward from M to E stage
`define HZ_FW_WE    2'b01   // forward from W to E stage
`define HZ_FW_NONE  2'b00   // no forward

`define HZ_FW_EF    2'b10   // forward from E to F stage
`define HZ_FW_MF    2'b01   // forward from M to F stage
