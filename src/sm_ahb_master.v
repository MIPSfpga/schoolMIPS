/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * AHB-Lite master 
 * 
 * Copyright(c) 2017-2018 Stanislav Zhelnio
 *                        Anton Kulichkov
 *                        Dmitriy Vlasov
 */

`include "ahb_lite.vh"

module sm_ahb_master
(
    input             clk,
    input             rst_n,

    input      [31:0] a,        // address
    input             we,       // write enable
    input      [31:0] wd,       // write data
    input             valid,    // read/write request
    output            ready,    // read/write done
    output     [31:0] rd,       // read data

    output            HCLK,
    output            HRESETn,
    output            HWRITE,
    output     [ 1:0] HTRANS,
    output     [31:0] HADDR,
    input      [31:0] HRDATA,
    output     [31:0] HWDATA,
    input             HREADY,
    input             HRESP          
);
    assign HCLK     = clk;
    assign HRESETn  = rst_n;
    assign HWRITE   = we;
    assign HTRANS   = valid ? `HTRANS_NONSEQ : `HTRANS_IDLE; //AHB single transfer only
    assign HADDR    = a;

    wire ahbReady = HREADY & ~HRESP; // AHB peripheral Ready and NoError
    wire memStart =  valid;
    wire memEnd   = ~valid & ahbReady;

    // memory request is pending
    wire memWait;
    wire memWait_next = memStart ? 1 :
                        memEnd   ? 0 : memWait;
    sm_register_c r_memWait(clk, rst_n, memWait_next, memWait);

    // AHB Ready and Error status have meaning only when there was a request before
    assign ready    = memWait ? ahbReady : 1'b1; 
    assign rd       = HRDATA;

    sm_register_we #(32) r_hwdata (clk, rst_n, valid, wd, HWDATA);
endmodule
