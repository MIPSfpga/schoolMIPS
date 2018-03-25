

`include "sm_config.vh"

module sm_matrix
(
    //bus side
    input             clk,
    input             rst_n,
    input      [31:0] bAddr,    // bus address
    input             bWrite,   // bus write enable
    input      [31:0] bWData,   // bus write data
    output     [31:0] bRData,   // bus read data

    //pin side
    input      [`SM_GPIO_WIDTH - 1:0] gpioInput, // GPIO output pins
    output     [`SM_GPIO_WIDTH - 1:0] gpioOutput, // GPIO intput pins
    output                            pwmOutput,  // PWM output pin
    output                            alsCS,      // Ligth Sensor chip select
    output                            alsSCK,     // Light Sensor SPI clock
    input                             alsSDO      // Light Sensor SPI data
);
    // bus wires
    wire [ 5:0] bSel;
    wire [31:0] bRData0;
    wire [31:0] bRData1;
    wire [31:0] bRData2;
    wire [31:0] bRData3;

    // bus selector
    sm_matrix_decoder decoder
    (
        .bAddr  ( bAddr ),
        .bSel   ( bSel  )
    );

    //bus read data mux
    sm_matrix_mux mux
    (
        .bSel   ( bSel    ),
        .out    ( bRData  ),
        .in0    ( bRData0 ),
        .in1    ( bRData1 ),
        .in2    ( bRData2 ),
        .in3    ( bRData3 ),
        .in4    ( 32'b0   ),    //reserved
        .in5    ( 32'b0   )     //reserved
    );

    // data memory
    wire bWrite0 = bWrite & bSel[0];

    sm_ram data_ram
    (
        .clk ( clk      ),
        .a   ( bAddr    ),
        .we  ( bWrite0  ),
        .wd  ( bWData   ),
        .rd  ( bRData0  )
    );

    // GPIO
    sm_gpio gpio
    (
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .bSel       ( bSel[1]    ),
        .bAddr      ( bAddr      ),
        .bWrite     ( bWrite     ),
        .bWData     ( bWData     ),
        .bRData     ( bRData1    ),
        .gpioInput  ( gpioInput  ),
        .gpioOutput ( gpioOutput )
    );

    // PWM
    sm_pwm pwm
    (
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .bSel       ( bSel[2]    ),
        .bAddr      ( bAddr      ),
        .bWrite     ( bWrite     ),
        .bWData     ( bWData     ),
        .bRData     ( bRData2    ),
        .pwmOutput  ( pwmOutput  )
    );

    // ALS
    sm_als als
    (
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .cs         ( alsCS      ),
        .sck        ( alsSCK     ),
        .sdo        ( alsSDO     ),
        .value      ( bRData3    )
    );

endmodule

`define SM_RAM_ADDR_MATCH   2'b00
`define SM_GPIO_ADDR_MATCH 12'h7f0
`define SM_PWM_ADDR_MATCH  12'h7f1
`define SM_ALS_ADDR_MATCH  12'h7f2

module sm_matrix_decoder
(
    input  [31:0] bAddr,
    output [ 5:0] bSel
);
    // Decode based on most significant bits of the address
    // RAM   0x00000000 - 0x00003fff
    assign bSel[0] = ( bAddr [ 15:14 ] == `SM_RAM_ADDR_MATCH);

    // GPIO  0x00007f00 - 0x00007f0f
    assign bSel[1] = ( bAddr [ 15:4  ] == `SM_GPIO_ADDR_MATCH);

    // PWM   0x00007f10 - 0x00007f1f
    assign bSel[2] = ( bAddr [ 15:4  ] == `SM_PWM_ADDR_MATCH);

    // ALS   0x00007f20 - 0x00007f2f
    assign bSel[3] = ( bAddr [ 15:4  ] == `SM_ALS_ADDR_MATCH);

    assign bSel[4] = 1'b0;  // reserved
    assign bSel[5] = 1'b0;  // reserved

endmodule

module sm_matrix_mux
(
    input  [ 5:0] bSel,
    output reg [31:0] out,
    input  [31:0] in0,
    input  [31:0] in1,
    input  [31:0] in2,
    input  [31:0] in3,
    input  [31:0] in4,
    input  [31:0] in5
);  
    always @*
        casez (bSel)
            default   : out = in0;
            6'b?????1 : out = in0;
            6'b????10 : out = in1;
            6'b???100 : out = in2;
            6'b??1000 : out = in3;
            6'b?10000 : out = in4;
            6'b100000 : out = in5;
        endcase
endmodule
