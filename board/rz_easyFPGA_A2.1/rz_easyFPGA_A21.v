module rz_easyFPGA_A21(
      input       CLK,
      input       KEY0,
		input       KEY1,
      output      [3:0]  LED

);

    // wires & inputs
    wire          clk;
    wire          clkIn     =  CLK;
    wire          rst_n     =  KEY0;
    wire          clkEnable =  ~KEY1;
	 wire [ 31:0 ] regData;

    //cores
    sm_top sm_top
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .clkDevide  ( 4'b1000   ),
        .clkEnable  ( clkEnable ),
        .clk        ( clk       ),
        .regAddr    ( 4'b0010   ),
        .regData    ( regData   )
    );

    //outputs
    assign LED[0] = clk;
    assign LED[3] = regData[2];
	 assign LED[2] = regData[1];
	 assign LED[1] = regData[0];


endmodule