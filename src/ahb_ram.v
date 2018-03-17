
`include "ahb_lite.vh"

module ahb_ram
#(
    parameter SIZE = 64 // memory size, in words
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
    assign HRESP = 1'b0;
    wire valid = HREADY & HSEL & HTRANS != `HTRANS_IDLE;

    sm_ram_busy #(SIZE) ram
    (
        .clk   ( HCLK      ),
        .rst_n ( HRESETn   ),
        .a     ( HADDR     ),    
        .we    ( HWRITE    ),   
        .wd    ( HWDATA    ),   
        .valid ( valid     ),
        .ready ( HREADYOUT ),
        .rd    ( HRDATA    )  
    );

endmodule
