
`include "ahb_lite.vh"

// onchip fast devices:
//  - scratchpad RAM
//  - caches
//  - AHB-Lite host side adapter

module sm_matrix
#(
    parameter SIZE = 64 // memory size, in words
)
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

    wire [ 1:0] sel;      // device selector (request stage)
    wire [ 1:0] sel_r;    // device selector (response stage)
    wire [ 1:0] sel_a;    // addr decoder output
    assign sel = valid ? sel_a : 2'b0;
    
    wire [ 1:0] readyout; // device ready
    wire [31:0] rdata;    // data from devices
    wire [31:0] rdata0;
    wire [31:0] rdata1;
    
    // fast onchip RAM
    sm_ram_outbuf scratchpad_ram
    (
        .clk    ( clk            ),
        .rst_n  ( rst_n          ),
        .a      ( a              ),    
        .we     ( we             ),   
        .wd     ( wd             ),   
        .valid  ( sel        [0] ),
        .ready  ( readyout   [0] ),
        .rd     ( rdata0         )
    );

    // AHB-Lite bus : external (slow) RAM and peripheral devices
    sm_ahb_master ahb_master
    (
        .clk      ( clk         ),
        .rst_n    ( rst_n       ),
   
        .a        ( a           ),        
        .we       ( we          ),       
        .wd       ( wd          ),       
        .valid    ( sel     [1] ),    
        .ready    ( readyout[1] ),    
        .rd       ( rdata1      ),       

        .HCLK     ( HCLK        ),
        .HRESETn  ( HRESETn     ),
        .HWRITE   ( HWRITE      ),
        .HTRANS   ( HTRANS      ),
        .HADDR    ( HADDR       ),
        .HRDATA   ( HRDATA      ),
        .HWDATA   ( HWDATA      ),
        .HREADY   ( HREADY      ),
        .HRESP    ( HRESP       )          
    );

    // interconnect part:
    //  address decoder
    sm_matrix_decoder decoder ( a, sel_a);

    //  request -> response stage selector
    sm_register_we #(2) r_sel ( clk, rst_n, ready, sel, sel_r );

    //  response mux
    sm_response_mux response_mux
    (
        .sel      ( sel_r    ),
        .rdata0   ( rdata0   ),
        .rdata1   ( rdata1   ),
        .readyout ( readyout ),
        .rdata    ( rd       ),
        .ready    ( ready    )
    );

endmodule

module sm_matrix_decoder
(
    input  [ 31:0 ] addr,
    output [  1:0 ] sel
);
    localparam SEL_AHB = 2'b10;
    localparam SEL_SCR = 2'b01;

    // Decode based on most significant bits of the address
    // Scratchpad RAM   : 0x00000000 - 0x1fffffff   
    // AHB-Lite devices : 0x20000000 - 0xffffffff
    assign sel = `SM_MEM_SCRATCHPAD ? SEL_SCR : SEL_AHB;

endmodule

module sm_response_mux
(
    input      [  1:0 ] sel,
    input      [ 31:0 ] rdata0,
    input      [ 31:0 ] rdata1,
    input      [  1:0 ] readyout,

    output reg [ 31:0 ] rdata,
    output reg          ready
);
    always @ (*)
        casez (sel)
            default : begin rdata = rdata0; ready = readyout[0]; end
            2'b?1   : begin rdata = rdata0; ready = readyout[0]; end
            2'b10   : begin rdata = rdata1; ready = readyout[1]; end           
        endcase
endmodule
