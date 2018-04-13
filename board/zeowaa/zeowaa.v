
module zeowaa
(
    input         clk_50,
    input  [ 5:2] key,
    input  [ 7:0] sw,
    output [11:0] led,
    output [ 7:0] hex,
    output [ 7:0] digit,
    output        buzzer
);
    // wires & inputs
    wire          clkCpu;
    wire          clkIn     =  clk_50;
    wire          rst_n     =  key[4];
    wire          clkEnable =   ~sw[  7] | ~key[5];
    wire [  3:0 ] clkDevide = { ~sw[6:5], 2'b00 };
    wire [  4:0 ] regAddr   =   ~sw[4:0];
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
    assign led[0]    = ~clkCpu;
    assign led[11:1] = ~regData[11:0];

    //hex out
    wire [ 31:0 ] h7segment = regData;
    wire clkHex;

    sm_clk_divider hex_clk_divider
    (
        .clkIn   ( clkIn  ),
        .rst_n   ( rst_n  ),
        .devide  ( 4'b0   ),
        .enable  ( 1'b1   ),
        .clkOut  ( clkHex )
    );

    sm_hex_display_8 sm_hex_display_8
    (
        .clock          ( clkHex    ),
        .resetn         ( rst_n     ),
        .number         ( h7segment ),
        .seven_segments ( hex[6:0]  ),
        .dot            ( hex[7]    ),
        .anodes         ( digit     )
    );

    assign buzzer = 1'b1;

endmodule
