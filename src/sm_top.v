/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects"
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU
 * 
 * Copyright(c) 2017 Stanislav Zhelnio
 *                   Alexander Romanov
 */

`include "sm_settings.vh"

//hardware top level module
module sm_top
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] clkDevide,
    input           clkEnable,
    output          clk,
    input   [ 4:0 ] regAddr,
    output  [31:0 ] regData
);
    //metastability input filters
    wire    [ 3:0 ] devide;
    wire            enable;
    wire    [ 4:0 ] addr;

    sm_debouncer #(.SIZE(4)) f0(clkIn, clkDevide, devide);
    sm_debouncer #(.SIZE(1)) f1(clkIn, clkEnable, enable);
    sm_debouncer #(.SIZE(5)) f2(clkIn, regAddr,   addr  );

    //cores
    //clock devider
    sm_clk_divider sm_clk_divider
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .devide     ( devide    ),
        .enable     ( enable    ),
        .clkOut     ( clk       )
    );

    //instruction memory
    wire    [31:0]  imAddr;
    wire    [31:0]  imData;
    sm_rom #(`SM_CONFIG_ROM_SIZE) reset_rom(imAddr, imData);

    // data memory & peripheral devices
    wire    [31:0]  dmAddr;
    wire            dmWe;
    wire    [31:0]  dmWData;
    wire    [31:0]  dmRData;
    wire            dmValid;
    wire            dmReady;

    // AHB-Lite signals for peripheral devices
    wire        HCLK;
    wire        HRESETn;
    wire        HSEL;
    wire        HWRITE;
    wire [ 1:0] HTRANS;
    wire [31:0] HADDR;
    wire [31:0] HRDATA;
    wire [31:0] HWDATA;
    wire        HREADY;
    wire        HRESP;

    // scratchpad and AHB-Lite host side
    `SM_RAM data_ram
    (
        .clk    ( clk     ),
        .rst_n  ( rst_n   ),

        `ifdef SM_CONFIG_AHB_LITE
        .HCLK    (HCLK    ),
        .HRESETn (HRESETn ),
        .HSEL    (HSEL    ),
        .HWRITE  (HWRITE  ),
        .HTRANS  (HTRANS  ),
        .HADDR   (HADDR   ),
        .HRDATA  (HRDATA  ),
        .HWDATA  (HWDATA  ),
        .HREADY  (HREADY  ),
        .HRESP   (HRESP   ),
        `endif

        .a      ( dmAddr  ),    
        .we     ( dmWe    ),   
        .wd     ( dmWData ),   
        .valid  ( dmValid ),
        .ready  ( dmReady ),
        .rd     ( dmRData )
    );

    //cpu core
    `SM_CPU sm_cpu
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( addr      ),
        .regData    ( regData   ),
        .imAddr     ( imAddr    ),
        .imData     ( imData    ),
        .dmAddr     ( dmAddr    ),
        .dmWe       ( dmWe      ),
        .dmWData    ( dmWData   ),
        .dmValid    ( dmValid   ),
        .dmReady    ( dmReady   ),
        .dmRData    ( dmRData   )
    );

    // peripheral devices
    ahb_matrix ahb_matrix
    (
        .HCLK    ( HCLK    ),
        .HRESETn ( HRESETn ),
        .HSEL    ( HSEL    ),
        .HWRITE  ( HWRITE  ),
        .HTRANS  ( HTRANS  ),
        .HADDR   ( HADDR   ),
        .HRDATA  ( HRDATA  ),
        .HWDATA  ( HWDATA  ),
        .HREADY  ( HREADY  ),
        .HRESP   ( HRESP   ) 
    );

endmodule

//metastability input debouncer module
module sm_debouncer
#(
    parameter SIZE = 1
)
(
    input                      clk,
    input      [ SIZE - 1 : 0] d,
    output reg [ SIZE - 1 : 0] q
);
    reg        [ SIZE - 1 : 0] data;

    always @ (posedge clk) begin
        data <= d;
        q    <= data;
    end

endmodule

//tunable clock devider
module sm_clk_divider
#(
    parameter shift  = 16,
              bypass = 0
)
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] devide,
    input           enable,
    output          clkOut
);
    wire [31:0] cntr;
    wire [31:0] cntrNext = cntr + 1;
    sm_register_we #(32) r_cntr(clkIn, rst_n, enable, cntrNext, cntr);

    assign clkOut = bypass ? clkIn 
                           : cntr[shift + devide];
endmodule
