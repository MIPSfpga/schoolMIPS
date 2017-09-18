
module nexys4
(
    input         clk,
    input         btnCpuReset,

    input         btnC,
    input         btnU,
    input         btnL,
    input         btnR,
    input         btnD,

    input  [15:0] sw,

    output [15:0] led,

    output        RGB1_Red,
    output        RGB1_Green,
    output        RGB1_Blue,
    output        RGB2_Red,
    output        RGB2_Green,
    output        RGB2_Blue,

    output [ 6:0] seg,
    output        dp,
    output [ 7:0] an,

    inout  [ 7:0] JA,
    inout  [ 7:0] JB,

    input         RsRx
);
    // wires & inputs
    wire          clkCpu;
    wire          clkIn     =  clk;
    wire          rst_n     =  btnCpuReset;
    wire          clkEnable =  sw [9] | btnU;
    wire [  3:0 ] clkDevide =  sw [8:5];
    wire [  4:0 ] regAddr   =  sw [4:0];
    wire [ 31:0 ] regData;

    //cores
    sm_top sm_top
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .clkDevide  ( clkDevide ),
        .clkEnable  ( clkEnable ),
        .clk        ( clkCpu    ),
        .regAddr    ( regAddr   ),
        .regData    ( regData   )
    );

    //outputs
    assign led[0]    = clkCpu;
    assign led[15:1] = regData[14:0];

    //hex out
    wire [ 31:0 ] h7segment = regData;
    wire clkHex;

    sm_clk_divider hex_clk_divider
    (
        .clkIn   ( clkIn  ),
        .rst_n   ( rst_n  ),
        .devide  ( 4'b1   ),
        .enable  ( 1'b1   ),
        .clkOut  ( clkHex )
    );

    sm_hex_display_8 sm_hex_display_8
    (
        .clock          ( clkHex    ),
        .resetn         ( rst_n     ),
        .number         ( h7segment ),

        .seven_segments ( seg       ),
        .dot            ( dp        ),
        .anodes         ( an        )
    );

    assign RGB1_Red   = 1'b0; 
    assign RGB1_Green = 1'b0; 
    assign RGB1_Blue  = 1'b0; 
    assign RGB2_Red   = 1'b0; 
    assign RGB2_Green = 1'b0; 
    assign RGB2_Blue  = 1'b0;

endmodule
