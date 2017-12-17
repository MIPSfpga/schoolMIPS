module labfor_top
(
    input               CLK,
    output  [  7:0 ]    HEX0,
    output  [  7:0 ]    HEX1,
    output  [  7:0 ]    LED,
    input   [  7:0 ]    SW
);
    // wires & inputs
    wire          clk;
    wire          clkIn     =  CLK;
    wire          rst_n     =  SW [7];
    wire          clkEnable =  SW [6];
    wire [  3:0 ] clkDevide =  4'b1000;
    wire [  4:0 ] regAddr   =  SW [4:0];
    wire [ 31:0 ] regData;

    //cores
    sm_top sm_top
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .clkDevide  ( clkDevide ),
        .clkEnable  ( clkEnable ),
        .clk        ( clk       ),
        .regAddr    ( regAddr   ),
        .regData    ( regData   )
    );

    //outputs
    assign LED[0]   = clk;
    assign LED[7:1] = regData[6:0];

    wire [ 31:0 ] h7segment = regData;

    assign HEX0 [7] = 1'b1;
    assign HEX1 [7] = 1'b1;

    sm_hex_display digit_1 ( h7segment [ 7: 4] , HEX1 [6:0] );
    sm_hex_display digit_0 ( h7segment [ 3: 0] , HEX0 [6:0] );

endmodule
