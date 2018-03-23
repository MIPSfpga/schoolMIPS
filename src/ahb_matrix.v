
`include "ahb_lite.vh"
`include "sm_settings.vh"

`define DEVICE_COUNT 3

// external devices
module ahb_matrix
(
    // Bus side
    input                         HCLK,
    input                         HRESETn,
    input                         HWRITE,
    input   [                1:0] HTRANS,
    input   [               31:0] HADDR,
    output  [               31:0] HRDATA,
    input   [               31:0] HWDATA,
    output                        HREADY,
    output                        HRESP,

    // GPIO
    input  [`SM_GPIO_WIDTH - 1:0] port_gpioIn,
    output [`SM_GPIO_WIDTH - 1:0] port_gpioOut
);
    //bus wires
    wire   [`DEVICE_COUNT  - 1:0] HSEL_R;      // effected data phase HSEL signal
    wire   [`DEVICE_COUNT  - 1:0] HSEL;        // effected addr phase HSEL signal
    wire   [`DEVICE_COUNT  - 1:0] HREADYOUT;
    wire   [                31:0] RDATA [`DEVICE_COUNT - 1:0];
    wire   [`DEVICE_COUNT  - 1:0] RESP;

    //Peripheral devices
    // RAM
    ahb_ram ram
    (
        .HCLK         ( HCLK         ),
        .HRESETn      ( HRESETn      ),
        .HSEL         ( HSEL     [0] ),
        .HWRITE       ( HWRITE       ),
        .HREADY       ( HREADY       ),
        .HTRANS       ( HTRANS       ),
        .HADDR        ( HADDR        ),
        .HRDATA       ( RDATA    [0] ),
        .HWDATA       ( HWDATA       ),
        .HREADYOUT    ( HREADYOUT[0] ),
        .HRESP        ( RESP     [0] ) 
    );

    // GPIO
    ahb_gpio gpio
    (
        .HCLK         ( HCLK         ),
        .HRESETn      ( HRESETn      ),
        .HSEL         ( HSEL     [1] ),
        .HWRITE       ( HWRITE       ),
        .HREADY       ( HREADY       ),
        .HTRANS       ( HTRANS       ),
        .HADDR        ( HADDR        ),
        .HRDATA       ( RDATA    [1] ),
        .HWDATA       ( HWDATA       ),
        .HREADYOUT    ( HREADYOUT[1] ),
        .HRESP        ( RESP     [1] ),
        .port_gpioIn  ( port_gpioIn  ),
        .port_gpioOut ( port_gpioOut )
    );

    // some new peripheral stub
    assign RDATA     [2] = 32'b0;
    assign HREADYOUT [2] = 1'b1;
    assign RESP      [2] = 1'b0;
    
    //Bus interconnection part
    ahb_decoder decoder
    (   
        .HADDR        ( HADDR        ),
        .HSEL         ( HSEL         )
    );

    sm_register_we #(`DEVICE_COUNT) response_hsel (HCLK, HRESETn, HREADY, HSEL, HSEL_R);

    ahb_response_mux response_mux
    (
        .HSEL_R       ( HSEL_R       ),
        .RDATA_0      ( RDATA    [0] ),
        .RDATA_1      ( RDATA    [1] ),
        .RDATA_2      ( RDATA    [2] ),
        .RESP         ( RESP         ),
        .HRDATA       ( HRDATA       ),
        .HRESP        ( HRESP        ),
        .HREADYOUT    ( HREADYOUT    ),
        .HREADY       ( HREADY       )
    );

endmodule


module ahb_decoder
(
    input  [               31:0] HADDR,
    output [`DEVICE_COUNT - 1:0] HSEL
);
    wire [31:0] addr = HADDR;

    assign HSEL[0] = `SM_MEM_AHB_RAM;
    assign HSEL[1] = `SM_MEM_AHB_GPIO;
    assign HSEL[2] = 1'b0; // some new peripheral stub

endmodule

//--------------------------------------------------------------------

module ahb_response_mux
(
    input      [`DEVICE_COUNT - 1:0] HSEL_R,
    // Verilog doesn't allow an I/O port to be a 2D array.
    // We can do it with some macros, but 
    // it will be too hard to read this code in this case
    input      [               31:0] RDATA_0,
    input      [               31:0] RDATA_1,
    input      [               31:0] RDATA_2,
    input      [`DEVICE_COUNT - 1:0] RESP,
    input      [`DEVICE_COUNT - 1:0] HREADYOUT,

    output reg [               31:0] HRDATA,
    output reg                       HRESP,
    output reg                       HREADY
);
    always @*
        casez (HSEL_R)
            3'b??1  : begin HRDATA = RDATA_0; HRESP = RESP[0]; HREADY = HREADYOUT[0]; end
            3'b?10  : begin HRDATA = RDATA_1; HRESP = RESP[1]; HREADY = HREADYOUT[1]; end
            3'b100  : begin HRDATA = RDATA_2; HRESP = RESP[2]; HREADY = HREADYOUT[2]; end
            default : begin HRDATA = 32'b0;   HRESP = 1'b1;    HREADY = 1'b1; end
        endcase
endmodule
