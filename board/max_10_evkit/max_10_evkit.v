module max_10_evkit(
      input       CLK,
      input       SW3_1,
      input       SW3_2,
      output      [4:0]  LED

);

    // wires & inputs
    wire          clk;
    wire          clkIn     =  CLK;
    wire          rst_n     =  SW3_1;
    wire          clkEnable =  ~SW3_2;
    wire [ 31:0 ] regData;

    //cores
    sm_top sm_top
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .clkDevide  ( 4'b1010   ),
        .clkEnable  ( clkEnable ),
        .clk        ( clk       ),
        .regAddr    ( 4'b0010   ),
        .regData    ( regData   )
    );

    //outputs
    assign LED[0]   = clk;
    assign LED[4:1] = ~{regData[0], regData[1], regData[2], regData[3]};

endmodule
