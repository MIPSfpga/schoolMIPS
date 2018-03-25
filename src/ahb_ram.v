/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * AHB-Lite RAM
 * 
 * Copyright(c) 2017-2018 Stanislav Zhelnio
 *                        Anton Kulichkov
 *                        Dmitriy Vlasov
 */

`include "ahb_lite.vh"

module ahb_ram
#(
    parameter WIDTH = 6 // memory internal bus width (determines RAM size)
)
(
    input            HCLK,
    input            HRESETn,
    input            HSEL,
    input            HWRITE,
    input            HREADY,
    input     [ 1:0] HTRANS,
    input     [31:0] HADDR,
    output    [31:0] HRDATA,
    input     [31:0] HWDATA,
    output           HREADYOUT,
    output           HRESP       
);
    // bus input decode
    wire request   = HREADY & HSEL & HTRANS != `HTRANS_IDLE;
    wire request_r = request & !HWRITE;

    wire request_w;
    wire request_w_new = request & HWRITE;
    sm_register_c r_request_w (HCLK, HRESETn, request_w_new, request_w);

    wire [31:0] addr_w;
    wire [31:0] addr_r = HADDR;
    sm_register_we #(32) r_addr_w (HCLK, HRESETn, request, HADDR, addr_w);

    // memory interface
    wire        mem_we    = request_w;
    wire [31:0] mem_wd    = HWDATA;
    wire [31:0] mem_addr  = request_w ? addr_w : addr_r;
    wire        mem_valid = request_r | request_w;
    wire        mem_ready;
    wire [31:0] mem_rd;

    sm_ram_busy #(WIDTH) ram
    (
        .clk   ( HCLK      ),
        .rst_n ( HRESETn   ),
        .a     ( mem_addr  ),    
        .we    ( mem_we    ),   
        .wd    ( mem_wd    ),   
        .valid ( mem_valid ),
        .ready ( mem_ready ),
        .rd    ( mem_rd    )  
    );

    // read after write hazard
    wire hz_raw;
    wire hz_raw_new = (request_r & request_w) | request_w_new;
    sm_register_c r_hz_raw (HCLK, HRESETn, hz_raw_new, hz_raw );

    // bus output
    assign HREADYOUT = ~hz_raw & mem_ready;
    assign HRDATA    = mem_rd;
    assign HRESP     = 1'b0;

endmodule
