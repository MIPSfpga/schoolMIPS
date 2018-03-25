/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * AHB-Lite gpio 
 * 
 * Copyright(c) 2017-2018 Stanislav Zhelnio
 */

`include "ahb_lite.vh"
`include "sm_settings.vh"

`define SM_GPIO_REG_INPUT   4'h0
`define SM_GPIO_REG_OUTPUT  4'h4

module ahb_gpio
(
    //bus side
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
    output           HRESP,

    //pin side
    input  [`SM_GPIO_WIDTH - 1:0] port_gpioIn,
    output [`SM_GPIO_WIDTH - 1:0] port_gpioOut
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

    // peripheral module interface
    wire        pm_we    = request_w;
    wire [31:0] pm_wd    = HWDATA;
    wire [31:0] pm_addr  = request_w ? addr_w : addr_r;
    wire        pm_valid = request_r | request_w;
    wire [31:0] pm_rd;

    sm_gpio gpio
    (
        .clk        ( HCLK         ),
        .rst_n      ( HRESETn      ),
        .bSel       ( pm_valid     ),
        .bAddr      ( pm_addr      ),
        .bWrite     ( pm_we        ),
        .bWData     ( pm_wd        ),
        .bRData     ( pm_rd        ),
        .gpioInput  ( port_gpioIn  ),
        .gpioOutput ( port_gpioOut )
    );

    // read after write hazard
    wire hz_raw;
    wire hz_raw_new = (request_r & request_w) | request_w_new;
    sm_register_c r_hz_raw (HCLK, HRESETn, hz_raw_new, hz_raw );

    // bus output
    assign HREADYOUT = ~hz_raw;
    assign HRDATA    = pm_rd;
    assign HRESP     = 1'b0;

endmodule


module sm_gpio
(
    //bus side
    input             clk,
    input             rst_n,
    input             bSel,
    input      [31:0] bAddr,
    input             bWrite,
    input      [31:0] bWData,
    output reg [31:0] bRData,

    //pin side
    input  [`SM_GPIO_WIDTH - 1:0] gpioInput,
    output [`SM_GPIO_WIDTH - 1:0] gpioOutput
);
    wire   [`SM_GPIO_WIDTH - 1:0] gpioIn;    // debounced input signals
    wire                          gpioOutWe; // output Pin value write enable
    wire   [`SM_GPIO_WIDTH - 1:0] gpioOut;   // output Pin next value

    assign gpioOut   = bWData [`SM_GPIO_WIDTH - 1:0];
    assign gpioOutWe = bSel & bWrite & (bAddr[3:0] == `SM_GPIO_REG_OUTPUT);

    sm_debouncer   #(`SM_GPIO_WIDTH) debounce(clk, gpioInput, gpioIn);
    sm_register_we #(`SM_GPIO_WIDTH) r_output(clk, rst_n, gpioOutWe, gpioOut, gpioOutput);

    localparam BLANK_WIDTH = 32 - `SM_GPIO_WIDTH;

    always @ (*)
        case(bAddr[3:0])
            default              : bRData = { { BLANK_WIDTH {1'b0}}, gpioIn  };
            `SM_GPIO_REG_INPUT   : bRData = { { BLANK_WIDTH {1'b0}}, gpioIn  };
            `SM_GPIO_REG_OUTPUT  : bRData = { { BLANK_WIDTH {1'b0}}, gpioOut };
        endcase

endmodule
