
module de0_cv
(
    input           CLOCK2_50,
    input           CLOCK3_50,
    inout           CLOCK4_50,
    input           CLOCK_50,
                   
    input           RESET_N,

    input   [ 3:0]  KEY,
    input   [ 9:0]  SW,

    output  [ 9:0]  LEDR,

    output  [ 6:0]  HEX0,
    output  [ 6:0]  HEX1,
    output  [ 6:0]  HEX2,
    output  [ 6:0]  HEX3,
    output  [ 6:0]  HEX4,
    output  [ 6:0]  HEX5,
                   
    output  [12:0]  DRAM_ADDR,
    output  [ 1:0]  DRAM_BA,
    output          DRAM_CAS_N,
    output          DRAM_CKE,
    output          DRAM_CLK,
    output          DRAM_CS_N,
    inout   [15:0]  DRAM_DQ,
    output          DRAM_LDQM,
    output          DRAM_RAS_N,
    output          DRAM_UDQM,
    output          DRAM_WE_N,
                   
    output  [ 3:0]  VGA_B,
    output  [ 3:0]  VGA_G,
    output          VGA_HS,
    output  [ 3:0]  VGA_R,
    output          VGA_VS,

    inout           PS2_CLK,
    inout           PS2_CLK2,
    inout           PS2_DAT,
    inout           PS2_DAT2,
                   
    output          SD_CLK,
    inout           SD_CMD,
    inout   [ 3:0]  SD_DATA,
                   
    inout   [35:0]  GPIO_0,
    inout   [35:0]  GPIO_1
);

    // wires & inputs
    wire          clk;
    wire          clkIn     =  CLOCK_50;
    wire          rst_n     =  KEY[0] & RESET_N;
    wire          clkEnable =  SW [9] | ~KEY[1];
    wire [  3:0 ] clkDevide =  SW [8:5];
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
    assign LEDR[0]   = clk;
    assign LEDR[9:1] = regData[8:0];

    wire [ 31:0 ] h7segment = regData;

    sm_hex_display digit_5 ( h7segment [23:20] , HEX5 [6:0] );
    sm_hex_display digit_4 ( h7segment [19:16] , HEX4 [6:0] );
    sm_hex_display digit_3 ( h7segment [15:12] , HEX3 [6:0] );
    sm_hex_display digit_2 ( h7segment [11: 8] , HEX2 [6:0] );
    sm_hex_display digit_1 ( h7segment [ 7: 4] , HEX1 [6:0] );
    sm_hex_display digit_0 ( h7segment [ 3: 0] , HEX0 [6:0] );

endmodule
