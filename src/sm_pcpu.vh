/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * the pipeline version of Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio
 */ 

`define HZ_FW_ME    2'b10   // forward from M to E stage
`define HZ_FW_WE    2'b01   // forward from W to E stage
`define HZ_FW_NONE  2'b00   // no forward

