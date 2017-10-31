
module de0_nano
(
    input           FPGA_CLK1_50,
    input   [ 1:0]  KEY,
    output  [ 7:0]  LED,
    input   [ 3:0]  SW
);

    // wires & inputs
    wire          clk;
    wire          clkIn     =  FPGA_CLK1_50;
    wire          rst_n     =  KEY[0];
    wire          clkEnable =  ~KEY[1];
    wire [  3:0 ] clkDevide =  4'b1000;
    wire [  4:0 ] regAddr   =  { 1'b0, SW [3:0] };
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

endmodule