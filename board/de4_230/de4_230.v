
module de4_230
(
    input          	GCLKIN,
    output          GCLKOUT_FPGA,
    input          	OSC_50_BANK2,
    input          	OSC_50_BANK3,
    input          	OSC_50_BANK4,
    input          	OSC_50_BANK5,
    input          	OSC_50_BANK6,
    input          	OSC_50_BANK7,
    input          	PLL_CLKIN_p,

    output  [7:0]   LED,
    input   [3:0]   BUTTON,
    input           CPU_RESET_n, // CPU Reset Push Button
    inout           EXT_IO,
    input   [7:0]   SW,          // DIP Switches
    input   [3:0]   SLIDE_SW,    // Slide switches
    output  [6:0]   SEG0_D,
    output          SEG0_DP,
    output  [6:0]   SEG1_D,
    output          SEG1_DP
);

    // wires & inputs
    wire          clk;
    wire          clkIn     =  OSC_50_BANK2;
    wire          rst_n     =  CPU_RESET_n;
    wire          clkEnable =  SW [7] | ~BUTTON[0];
    wire [  3:0 ] clkDevide =  SW [3:0];
    wire [  4:0 ] regAddr   =  { ~BUTTON[1], SLIDE_SW };
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

    assign SEG0_DP = 1'b1;
    assign SEG1_DP = 1'b1;

    sm_hex_display digit_1 ( h7segment [ 7: 4] , SEG1_D );
    sm_hex_display digit_0 ( h7segment [ 3: 0] , SEG0_D );

endmodule
